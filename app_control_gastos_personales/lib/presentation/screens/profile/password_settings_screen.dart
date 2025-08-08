import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/infrastucture/services/auth_service.dart';

class PasswordSettingsScreen extends StatefulWidget {
  // Corregido: Definir correctamente el nombre de la ruta
  static const String name = 'password-settings-screen';

  const PasswordSettingsScreen({super.key});

  @override
  State<PasswordSettingsScreen> createState() => _PasswordSettingsScreenState();
}

class _PasswordSettingsScreenState extends State<PasswordSettingsScreen> {
  final AuthService _authService = AuthService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validaciones
    if (currentPassword.isEmpty) {
      _showSnackBar('Por favor ingresa tu contraseña actual.');
      return;
    }

    if (newPassword.isEmpty) {
      _showSnackBar('Por favor ingresa una nueva contraseña.');
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('La nueva contraseña debe tener al menos 6 caracteres.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('Las contraseñas no coinciden.');
      return;
    }

    if (currentPassword == newPassword) {
      _showSnackBar('La nueva contraseña debe ser diferente a la actual.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.changePassword(currentPassword, newPassword);
      _showSnackBar('Contraseña cambiada correctamente.');
      
      // Limpiar campos
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      
      // Opcional: volver a la pantalla anterior
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('correctamente') 
              ? AppTheme.verde 
              : Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.verde,
      body: Column(
        children: [
          const SizedBox(height: 60),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Text(
                  'Cambiar Contraseña',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 24), // Para centrar el título
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Contenedor blanco con formulario
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
                    const SizedBox(height: 30),

                    // Contraseña actual
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Contraseña Actual',
                      obscureText: _obscureCurrentPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Nueva contraseña
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'Nueva Contraseña',
                      obscureText: _obscureNewPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Confirmar nueva contraseña
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar Nueva Contraseña',
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 40),

                    // Botón de cambiar contraseña
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.verde,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Cambiar Contraseña',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: AppTheme.verdeOscuro,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.verdeOscuro,
            ),
          ),
        ),
      ),
    );
  }
}
