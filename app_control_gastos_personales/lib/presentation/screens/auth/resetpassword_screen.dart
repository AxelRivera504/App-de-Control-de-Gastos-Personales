import 'package:app_control_gastos_personales/application/controllers/auth/resetpasword_controller.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custominputfield.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/screens/screens.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/utils/snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  static const name = 'resetpassword-screen';
  final String email; 
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtPasswordConfirm = TextEditingController();

  ResetPasswordScreen({super.key, required this.email});

  final regexSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Contraseña requerida';
    if (!regexSpecialChar.hasMatch(value) || value.replaceAll(RegExp(r'[!@#$%^&*(),.?":{}|<>]'), '').length != value.length - 1)  return 'La contraseña debe contener al menos un caracter especial y un numero';
    if (txtPassword.text != txtPasswordConfirm.text) return 'Las contraseñas no coinciden';
    return null;
  }

  void _onChangePassword(BuildContext context, ResetPasswordController resetPasswordController) async{
    if (_formKey.currentState!.validate()) {
      final result = await resetPasswordController.resetPassword(email,txtPassword.text.trim());

      if(result == null){
        CustomSnackBar.show(
          context,
          "Ocurrió un error inesperado.",
          backgroundColor: AppTheme.anarajando,
          textColor: AppTheme.blancoPalido,
        );
        return;
      }

      if(result == "not_found"){
        CustomSnackBar.show(
          context,
          "Usuario no encontrado.",
          backgroundColor: AppTheme.anarajando,
          textColor: AppTheme.blancoPalido,
        );
        return;
      }

      if(result == "inactive"){
        CustomSnackBar.show(
          context,
          "Su cuenta está desactivada.",
          backgroundColor: AppTheme.anarajando,
          textColor: AppTheme.blancoPalido,
        );
        return;
      }

      CustomSnackBar.show(context, "La contraseña ha sido restablecida exitosamente");
      context.goNamed(
        LoginScreen.name
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetPasswordController = Get.put(ResetPasswordController());

    return BaseDesign(
      title: 'Cambiar Contraseña', 
      spaceHeader: 50,
      child: Obx(
          () => Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Nueva Contraseña",
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Confirmar nueva Contraseña",
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
                controller: txtPasswordConfirm,
                hintText: '**********',
                validator: _validatePassword,
                isPassword: true,
              ),
              const SizedBox(height: 40),
              resetPasswordController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () => _onChangePassword(context, resetPasswordController),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verde,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text("Cambiar Contraseña", style: TextStyle(color: AppTheme.verdeOscuro, fontSize: 16, fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}