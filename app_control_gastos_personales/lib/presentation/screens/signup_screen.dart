
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/screens/home_screen.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custominputfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  static const name = 'login-screen';
  final int pageIndex;
  const SignUpScreen({super.key, required this.pageIndex});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscureText = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController txtUsuario = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();

  void _toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Container(
              decoration: const BoxDecoration(color: AppTheme.verde),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 80),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Crear cuenta",
                      style: TextStyle(
                        color: AppTheme.verdeOscuro,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.blancoPalido,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(48),
                          topRight: Radius.circular(48),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
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
                                validator: _validateEmail,
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
                                controller: txtUsuario,
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
                                controller: txtUsuario,
                                hintText: '+504 1222-3344',
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
                                controller: txtPassword,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}