import 'package:app_control_gastos_personales/application/controllers/auth/auth_controller.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custominputfield.dart';
import 'package:app_control_gastos_personales/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/utils/main_navigation_screen.dart';

class LoginScreen extends StatelessWidget {
  static const name = 'login-screen';

  final _formKey = GlobalKey<FormState>();
  final txtUsuario = TextEditingController();
  final txtPassword = TextEditingController();

  LoginScreen({super.key});

  void _onLoginPressed(
    BuildContext context,
    AuthController authController,
  ) async {
    if (_formKey.currentState!.validate()) {
      final result = await authController.login(
        txtUsuario.text.trim(),
        txtPassword.text.trim(),
      );

      switch (result) {
        case null:
          CustomSnackBar.show(
            context,
            "Ocurrió un error inesperado",
            backgroundColor: AppTheme.anarajando,
          );
          break;
        case 'not_found':
          CustomSnackBar.show(
            context,
            "Usuario no encontrado",
            backgroundColor: AppTheme.anarajando,
          );
          break;
        case 'inactive':
          CustomSnackBar.show(
            context,
            "Cuenta desactivada",
            backgroundColor: AppTheme.anarajando,
          );
          break;
        case 'wrong_password':
          CustomSnackBar.show(
            context,
            "Contraseña incorrecta",
            backgroundColor: AppTheme.anarajando,
          );
          break;
        default:
          CustomSnackBar.show(context, "Inicio de sesión exitoso");
          context.goNamed(MainNavigationScreen.name);


      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Correo electrónico requerido';
    if (!value.contains('@')) return 'Correo inválido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Contraseña requerida';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    return BaseDesign(
      title: 'Iniciar Sesión',
      child: Obx(
        () => Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Correo Electrónico",
                    style: TextStyle(
                      color: AppTheme.verdeOscuro,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomInputField(
                controller: txtUsuario,
                hintText: 'ejemplo@correo.com',
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Contraseña",
                    style: TextStyle(
                      color: AppTheme.verdeOscuro,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomInputField(
                controller: txtPassword,
                hintText: '**********',
                validator: _validatePassword,
                isPassword: true,
              ),
              const SizedBox(height: 40),
              authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: () => _onLoginPressed(context, authController),
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppTheme.verde,
                        ),
                        child: Center(
                          child: Text(
                            "Iniciar Sesión",
                            style: TextStyle(
                              color: AppTheme.verdeOscuro,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => context.go('/forgetpassword'),
                child: const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    color: AppTheme.verdeOscuro,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => context.go('/signup'),
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: AppTheme.verdePalido,
                  ),
                  child: Center(
                    child: Text(
                      "Registrarse",
                      style: TextStyle(
                        color: AppTheme.verdeOscuro,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
