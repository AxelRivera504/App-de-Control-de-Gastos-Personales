import 'dart:async';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/controllers/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  static const name = 'splash-screen';
  final int pageIndex;
  const SplashScreen({super.key, required this.pageIndex});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

 @override
void initState() {
  super.initState();

  Timer(const Duration(seconds: 2), () {
    final session = SessionController.instance;

    if (session.userId == null) {
      context.go('/login/0'); // 👈 Redirige al LoginScreen
    } else {
      context.go('/home/0');  // 👈 Redirige al HomeScreen
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.blancoPalido,
      body: Center(
        child: Center(
          child: Text('Splash Screen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.verdeOscuro)),
        ),
      ),
    );
  }
}
