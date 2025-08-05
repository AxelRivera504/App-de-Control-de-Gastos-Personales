import 'dart:convert';

import 'package:app_control_gastos_personales/infrastucture/datasources/user_datasource.dart';
import 'package:app_control_gastos_personales/presentation/screens/screens.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custominputfield.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/utils/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';


class ForgetPasswordScreen extends StatefulWidget {
  static const name = 'forgetpassword-screen';
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreentate();
}
class _ForgetPasswordScreentate extends State<ForgetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController txtUsuario = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Correo electrónico requerido';
     if (!value.contains('@')) return 'Correo invalido';
    return null;
  }

 void _verifyUserByEmail() async {
  if (_formKey.currentState!.validate()) {
    final email = txtUsuario.text.trim();

    final userRepository = UserDataSource();
    final result = await userRepository.verifyUserByEmail(email);

    if (result == null) {
      CustomSnackBar.show(
        context,
        "Ocurrió un error inesperado.",
        backgroundColor: AppTheme.anarajando,
        textColor: AppTheme.blancoPalido,
      );
      return;
    }
    if (result == 'not_found') {
      CustomSnackBar.show(
        context,
        "No se encontró un usuario con el correo electrónico digitado.",
        backgroundColor: AppTheme.anarajando,
        textColor: AppTheme.blancoPalido,
      );
      return;
    }
    if (result == 'inactive') {
      CustomSnackBar.show(
        context,
        "Su cuenta está desactivada.",
        backgroundColor: AppTheme.anarajando,
        textColor: AppTheme.blancoPalido,
      );
      return;
    }
      

    final resultCode = await userRepository.generateRecoveryCode(email);
    EnviarEmail(email, resultCode!);
    context.goNamed(
      VerifyCodeScreen.name,
      extra: {'email': email},
    );

    CustomSnackBar.show(context, "Se te ha enviado un código de recuperación a su correo electrónico.");
  }
}


Future EnviarEmail(String email, String codigo) async{
    final response = await http.post(
    Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
    headers: {
      'Content-Type': 'application/json',
      'origin': 'http://localhost' // importante para test local
    },
    body: json.encode({
      "service_id": "service_xakeg8l",
      "template_id": "template_9bgfxb6",
      "user_id": "qvliEpwtjZVMx7b1d",
      "template_params": {
        "email": email,
        "code": codigo
      }
    }),
  );

    
    return response.statusCode;
  }


  @override
  Widget build(BuildContext context) {
    return BaseDesign(
      header: const Text(
        "Restablecer Contraseña",
        style: TextStyle(
          color: AppTheme.verdeOscuro,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ingresa tu dirección de correo electrónico asociada a tu cuenta y te enviaremos un código para restablecer tu contraseña.",
                  style: TextStyle(
                    color: AppTheme.verdeOscuro,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),


            // Label y textformdield correo electrónico
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Introduce tu correo Electrónico",
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

            // Botón iniciar sesión
            GestureDetector(
              onTap: _verifyUserByEmail,
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppTheme.verde,
                ),
                child: Center(
                  child: Text(
                    "Siguiente",
                    style: TextStyle(
                      color: AppTheme.verdeOscuro,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón registrarse
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