import 'package:app_control_gastos_personales/application/controllers/auth/register_controller.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/screens/auth/login_screen.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custominputfield.dart';
import 'package:app_control_gastos_personales/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatelessWidget {
  static const name = 'singup-screen';
  final _formKey = GlobalKey<FormState>();
  final _txtUsuario = TextEditingController();
  final _txtCorreo = TextEditingController();
  final _txtNumeroTelefono = TextEditingController();
  final _txtPassword = TextEditingController();
  final _txtPasswordConfirm = TextEditingController();

  SignUpScreen({super.key});

  final regexSpecialChar = RegExp(r'[!@#\\$%^&*(),.?":{}|<>]');

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty)return 'Nombre completo requerido';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty)return 'Correo eléctronico requerido';
    if (!value.contains('@')) return 'Correo invalido';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Número requerido';
    // final pattern = RegExp(r'^\+504 \d{4}-\d{4}\$');
    // if (!pattern.hasMatch(value)) return 'Formato inválido (+504 0000-0000)';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Contraseña requerida';
    if (!regexSpecialChar.hasMatch(value))return 'Debe contener al menos un caracter especial';
    if (!RegExp(r'.*[0-9].*').hasMatch(value))return 'Debe contener al menos un número';
    if (_txtPassword.text != _txtPasswordConfirm.text)return 'Las contraseñas no coinciden';
    return null;
  }

  void _onRegisterPressed(
    BuildContext context,
    RegisterController controller,
  ) async {
    if (_formKey.currentState!.validate()) {
      final result = await controller.registerUser(
        name: _txtUsuario.text.trim(),
        email: _txtCorreo.text.trim(),
        phone: _txtNumeroTelefono.text.trim(),
        password: _txtPassword.text.trim(),
      );

      if (result) {
        CustomSnackBar.show(context, "Usuario registrado exitosamente");
        context.goNamed(LoginScreen.name);
      } else {
        CustomSnackBar.show(
          context,
          "Error al registrar usuario",
          backgroundColor: AppTheme.anarajando,
          textColor: AppTheme.blancoPalido,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerController = Get.put(RegisterController());

    return BaseDesign(
      title: 'Crear Cuenta',
      spaceHeader: 50,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildLabel("Nombre Completo"),
            const SizedBox(height: 10),
            CustomInputField(
              controller: _txtUsuario,
              hintText: 'Nombre de usuario',
              validator: _validateName,
            ),
            const SizedBox(height: 20),
            _buildLabel("Correo electrónico"),
            const SizedBox(height: 10),
            CustomInputField(
              controller: _txtCorreo,
              hintText: 'ejemplo@ejemplo.com',
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildLabel("Número de teléfono"),
            const SizedBox(height: 10),
            CustomInputField(
              controller: _txtNumeroTelefono,
              hintText: '+504 0000-0000',
              validator: _validatePhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _buildLabel("Contraseña"),
            const SizedBox(height: 10),
            CustomInputField(
              controller: _txtPassword,
              hintText: '**********',
              validator: _validatePassword,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            _buildLabel("Confirmar Contraseña"),
            const SizedBox(height: 10),
            CustomInputField(
              controller: _txtPasswordConfirm,
              hintText: '**********',
              validator: _validatePassword,
              isPassword: true,
            ),
            const SizedBox(height: 40),
            Obx(
              () => registerController.isLoading.value
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: () =>
                          _onRegisterPressed(context, registerController),
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppTheme.verde,
                        ),
                        child: const Center(
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
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: const Text(
                "¿Ya tienes una cuenta? Inicia sesión",
                style: TextStyle(
                  color: AppTheme.verdeOscuro,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.verdeOscuro,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
