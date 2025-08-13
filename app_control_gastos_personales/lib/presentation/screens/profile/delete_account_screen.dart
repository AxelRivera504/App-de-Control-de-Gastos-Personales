import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/infrastucture/services/auth_service.dart';

import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custominputfield.dart';
import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:app_control_gastos_personales/presentation/widgets/info_card.dart';
import 'package:app_control_gastos_personales/presentation/widgets/bullet_point.dart';
import 'package:app_control_gastos_personales/presentation/widgets/primary_button.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custom_snackbar_mixin.dart';

class DeleteAccountScreen extends StatefulWidget {
  static const name = 'delete-account-screen';
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> with CustomSnackBarMixin {
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String _currentUserName = '';
  String _currentUserEmail = '';

  static const List<String> _warningMessages = [
    'Todos tus datos serán eliminados permanentemente',
    'No podrás acceder nuevamente a tu cuenta',
    'Esta acción es completamente irreversible',
    'Se cerrará tu sesión inmediatamente',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserInfo();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserInfo() async {
    try {
      if (await _authService.isUserAuthenticated()) {
        final userData = await _authService.getCurrentUserData();
        final userEmail = await _authService.getCurrentUserEmail();
        
        if (mounted) {
          setState(() {
            _currentUserName = userData?['name'] ?? 'Usuario';
            _currentUserEmail = userEmail ?? '';
          });
        }
      }
    } catch (e) {
      print('Error cargando información del usuario: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Cuenta eliminada'),
        content: const Text('Tu cuenta ha sido eliminada exitosamente.'),
        actions: [
          TextButton(
            onPressed: () => context.go('/initial'),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showFinalConfirmationDialog() {
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro? Esta acción es irreversible y borrará todos tus datos.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Usuario: $_currentUserName'),
            Text('Email: $_currentUserEmail'),
            const SizedBox(height: 8),
            const Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performAccountDeletion();
            },
            child: const Text(
              'Sí, eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performAccountDeletion() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      await _authService.deleteAccount(_passwordController.text.trim());
      
      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog(e.toString());
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (_passwordController.text.trim().isEmpty) {
      _showErrorDialog('Por favor, ingresa tu contraseña.');
      return;
    }

    if (!await _authService.isUserAuthenticated()) {
      _showErrorDialog('No hay usuario autenticado.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isValidPassword = await _authService.verifyCurrentUserPassword(
        _passwordController.text.trim()
      );

      if (!isValidPassword) {
        setState(() => _isLoading = false);
        _showErrorDialog('Contraseña incorrecta.');
        return;
      }

      _showFinalConfirmationDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDesign(
      header: const NavigationHeader(
        title: 'Eliminar Cuenta',
        showNotifications: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentUserName.isNotEmpty) ...[
            InfoCard(
              title: 'Cuenta a eliminar:',
              content: 'Usuario: $_currentUserName\nEmail: $_currentUserEmail',
              backgroundColor: Colors.blue.withOpacity(0.1),
              borderColor: Colors.blue.withOpacity(0.3),
              textColor: AppTheme.verdeOscuro,
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            '¿Seguro que quieres eliminar tu cuenta?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.verdeOscuro,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Esta acción eliminará permanentemente todos tus datos.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          
          ..._warningMessages.map((message) => BulletPoint(text: message)),
          
          const SizedBox(height: 24),
          const Text(
            'Para confirmar, ingresa tu contraseña:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.verdeOscuro,
            ),
          ),
          const SizedBox(height: 12),
          CustomInputField(
            controller: _passwordController,
            hintText: 'Contraseña actual',
            isPassword: true,
          ),
          const SizedBox(height: 30),
          
          PrimaryButton(
            text: 'Eliminar Cuenta Permanentemente',
            backgroundColor: Colors.redAccent,
            isLoading: _isLoading,
            onPressed: _deleteAccount,
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.verdePalido,
                foregroundColor: AppTheme.verdeOscuro,
                side: const BorderSide(color: AppTheme.verde),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
