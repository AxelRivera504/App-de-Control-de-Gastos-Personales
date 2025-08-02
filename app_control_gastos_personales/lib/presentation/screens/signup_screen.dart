
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/views/base_view.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/screens/home_screen.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custominputfield.dart';

class SignUpScreen extends StatefulWidget {
  static const name = 'singup-screen';
  final int pageIndex;
  const SignUpScreen({super.key, required this.pageIndex});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController txtUsuario = TextEditingController();
  final TextEditingController txtCorreo = TextEditingController();
  final TextEditingController txtNumeroTelefono = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
    final TextEditingController txtPasswordConfirm = TextEditingController();

  final regexSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nombre completo requerido';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Correo eléctronico requerido';
    if (!value.contains('@')) return 'Correo invalido';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Número requerido';
    final pattern = RegExp(r'^\+504 \d{4}-\d{4}$');
    if (!pattern.hasMatch(value)) return 'Formato inválido (+504 0000-0000)';
    return null;
  }


  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Contraseña requerida';
    if (!regexSpecialChar.hasMatch(value) || value.replaceAll(RegExp(r'[!@#$%^&*(),.?":{}|<>]'), '').length != value.length - 1)  return 'La contraseña debe contener al menos un caracter especial y un numero';
    if (txtPassword.text != txtPasswordConfirm.text) return 'Las contraseñas no coinciden';
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(message),
      ),
    );
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      _showSnackBar("¡Validación exitosa! Usuario: ${txtUsuario.text}");
      context.goNamed(
        HomeScreen.name,
        pathParameters: {'page': '0'}
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Crear Cuenta', 
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),

            //Label y textformdield nombre completo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nombre Completo",
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
              hintText: 'Nombre de usuario',
              validator: _validateName,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Correo electrónico",
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
              controller: txtCorreo,
              hintText: 'ejemplo@ejemplo.com',
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Numero de telefono",
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
              controller: txtNumeroTelefono,
              hintText: '+504 0000-0000',
              validator: _validatePhone,
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Confirmar Contraseña",
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
              onTap: () => context.go('/login/0'),
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