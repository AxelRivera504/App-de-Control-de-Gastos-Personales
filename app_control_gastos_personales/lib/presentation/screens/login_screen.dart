import 'package:app_control_gastos_personales/presentation/widgets/custominputfield.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/screens/home_screen.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  static const name = 'login-screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreentate();
}
class _LoginScreentate extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController txtUsuario = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Correo electrónico requerido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Contraseña requerida';
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.verde,
        content: Text(message, style: TextStyle(color: AppTheme.verdeOscuro)),
      ),
    );
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      _showSnackBar("¡Validación exitosa! Usuario: ${txtUsuario.text}");
      final session  = SessionController.instance;
      session.setSession('123', '1321231231', DateTime.timestamp());
      context.goNamed(
        HomeScreen.name
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDesign(
      title: 'Iniciar Sesión',
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),

            // Label y textformdield correo electrónico
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
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

            // Label y textformdield contraseña
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
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

            // Botón iniciar sesión
            GestureDetector(
              onTap: _onLoginPressed,
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

            // Enlace para olvidaste tu contraseña
            GestureDetector(
              onTap: () => context.go('/signup'),
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
          ],
        ),
      ),
    );
  }
}