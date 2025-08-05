
import 'package:app_control_gastos_personales/infrastucture/datasources/user_datasource.dart';
import 'package:app_control_gastos_personales/presentation/screens/screens.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custominputfield.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const name = 'resetpassword-screen';
  final String email; 
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}
class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtPasswordConfirm = TextEditingController();

  final regexSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Contraseña requerida';
    if (!regexSpecialChar.hasMatch(value) || value.replaceAll(RegExp(r'[!@#$%^&*(),.?":{}|<>]'), '').length != value.length - 1)  return 'La contraseña debe contener al menos un caracter especial y un numero';
    if (txtPassword.text != txtPasswordConfirm.text) return 'Las contraseñas no coinciden';
    return null;
  }

  void _onChangePassword() async{
    if (_formKey.currentState!.validate()) {
      final userRepository = UserDataSource();
      final result = await userRepository.updateUserPassword(widget.email,txtPassword.text.trim());

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
    return BaseDesign(
      title: 'Cambiar Contraseña', 
      spaceHeader: 50,
      child: Form(
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
            GestureDetector(
              onTap: _onChangePassword,
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppTheme.verde,
                ),
                child: Center(
                  child: Text(
                    "Cambiar Contraseña",
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
}