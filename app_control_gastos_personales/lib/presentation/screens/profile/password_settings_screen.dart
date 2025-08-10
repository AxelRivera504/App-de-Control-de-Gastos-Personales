import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/infrastucture/services/auth_service.dart';
// Importar los widgets nuevos
import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:app_control_gastos_personales/presentation/widgets/password_input_field.dart';
import 'package:app_control_gastos_personales/presentation/widgets/info_card.dart';
import 'package:app_control_gastos_personales/presentation/widgets/primary_button.dart';
import 'package:app_control_gastos_personales/presentation/widgets/snackbar_mixin.dart';

class PasswordSettingsScreen extends StatefulWidget {
  static const String name = 'password-settings-screen';
  const PasswordSettingsScreen({super.key});

  @override
  State<PasswordSettingsScreen> createState() => _PasswordSettingsScreenState();
}

class _PasswordSettingsScreenState extends State<PasswordSettingsScreen> with SnackBarMixin {
  final AuthService _authService = AuthService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _hasSpecialCharacter(String password) =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

  String? _validatePassword() {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      return 'Por favor ingresa tu contraseña actual.';
    }
    if (newPassword.isEmpty) {
      return 'Por favor ingresa una nueva contraseña.';
    }
    if (newPassword.length < 6) {
      return 'La nueva contraseña debe tener al menos 6 caracteres.';
    }
    if (!_hasSpecialCharacter(newPassword)) {
      return 'La nueva contraseña debe contener al menos un carácter especial (!@#\$%^&*(),.?":{}|<>).';
    }
    if (newPassword != confirmPassword) {
      return 'Las contraseñas no coinciden.';
    }
    if (currentPassword == newPassword) {
      return 'La nueva contraseña debe ser diferente a la actual.';
    }
    return null;
  }

  void _changePassword() async {
    final validationError = _validatePassword();
    if (validationError != null) {
      showSnackBar(context, validationError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.changePassword(
        _currentPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );
      
      showSnackBar(context, 'Contraseña cambiada correctamente.', isSuccess: true);
      _clearFields();
      
      if (mounted) context.pop();
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.verde,
      body: Column(
        children: [
          const SizedBox(height: 60),
          const NavigationHeader(title: 'Cambiar Contraseña'),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.blancoPalido,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Por tu seguridad, necesitamos verificar tu identidad antes de cambiar tu contraseña.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.verdeOscuro,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const InfoCard(
                      title: 'Requisitos para la nueva contraseña:',
                      content: '• Mínimo 6 caracteres\n• Al menos un carácter especial (!@#\$%^&*(),.?":{}|<>)',
                    ),
                    const SizedBox(height: 25),
                    PasswordInputField(
                      controller: _currentPasswordController,
                      label: 'Contraseña Actual',
                    ),
                    const SizedBox(height: 20),
                    PasswordInputField(
                      controller: _newPasswordController,
                      label: 'Nueva Contraseña',
                    ),
                    const SizedBox(height: 20),
                    PasswordInputField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar Nueva Contraseña',
                    ),
                    const SizedBox(height: 40),
                    PrimaryButton(
                      text: 'Cambiar Contraseña',
                      isLoading: _isLoading,
                      onPressed: _changePassword,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
