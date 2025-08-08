import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custominputfield.dart';
import 'package:app_control_gastos_personales/infrastucture/services/auth_service.dart';

class DeleteAccountScreen extends StatefulWidget {
  static const name = 'delete-account-screen';
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String _currentUserName = '';
  String _currentUserEmail = '';

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
      // Verificar contraseña antes de mostrar confirmación final
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

  Widget _buildBullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BaseDesign(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Text(
            'Eliminar Cuenta',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Icon(Icons.notifications_none, color: Colors.white),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del usuario actual
          if (_currentUserName.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cuenta a eliminar:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.verdeOscuro,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Usuario: $_currentUserName',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    'Email: $_currentUserEmail',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
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
          
          _buildBullet('Todos tus datos serán eliminados permanentemente'),
          _buildBullet('No podrás acceder nuevamente a tu cuenta'),
          _buildBullet('Esta acción es completamente irreversible'),
          _buildBullet('Se cerrará tu sesión inmediatamente'),
          
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
          
          // Botón de eliminar
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _deleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Eliminar Cuenta Permanentemente',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Botón de cancelar
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
