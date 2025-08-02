import 'package:app_control_gastos_personales/utils/session_controller.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  static const name = 'splash-screen';
  const SplashScreen({super.key});

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
      context.go('/login'); 
    } else {
      context.go('/home');
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
