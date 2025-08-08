import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custominputfield.dart';

class DeleteAccountScreen extends StatefulWidget {
  static const name = 'delete-account-screen';
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<String?> _getCurrentUserEmail() async {
    // reemplazar por la lógica real de autenticación
    return 'usuario@example.com';
  }

  Future<bool> _verifyPassword(String email, String password) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return false;
      return query.docs.first.get('password') == password;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _performAccountDeletion(String email) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return false;
      await query.docs.first.reference.update({
        'active': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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

  void _showFinalConfirmationDialog(String email) {
    setState(() => _isLoading = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: const Text(
          '¿Estas seguro? Esta accion es irreversible y borrara todos tus datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              bool deleted = await _performAccountDeletion(email);
              setState(() => _isLoading = false);
              deleted
                  ? _showSuccessDialog()
                  : _showErrorDialog('Error al eliminar la cuenta.');
            },
            child: const Text('Si, eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (_passwordController.text.trim().isEmpty) {
      _showErrorDialog('Por favor, ingresa tu contraseña.');
      return;
    }

    setState(() => _isLoading = true);

    String? userEmail = await _getCurrentUserEmail();
    if (userEmail == null) {
      _showErrorDialog('No se pudo obtener el usuario.');
      setState(() => _isLoading = false);
      return;
    }

    bool valid = await _verifyPassword(userEmail, _passwordController.text.trim());
    if (!valid) {
      _showErrorDialog('Contraseña incorrecta.');
      setState(() => _isLoading = false);
      return;
    }

    _showFinalConfirmationDialog(userEmail);
  }

  Widget _buildBullet(String text) => Text(
        '• $text',
        style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
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
          const Text('Eliminar Cuenta',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Icon(Icons.notifications_none, color: Colors.white),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Seguro que quieres eliminar tu cuenta?',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.verdeOscuro),
          ),
          const SizedBox(height: 12),
          const Text(
            'Esta accion eliminara permanentemente todos tus datos.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
          _buildBullet('Todos tus datos seran eliminados'),
          _buildBullet('No podras acceder nuevamente'),
          _buildBullet('Esta accion es irreversible'),
          const SizedBox(height: 24),
          const Text(
            'Ingresa tu contraseña:',
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.verdeOscuro),
          ),
          const SizedBox(height: 12),
          CustomInputField(
            controller: _passwordController,
            hintText: 'Contraseña',
            isPassword: true,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _deleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.verde,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Si, Eliminar Cuenta',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => context.pop(),
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
