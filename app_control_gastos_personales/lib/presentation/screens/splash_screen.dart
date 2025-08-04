import 'package:app_control_gastos_personales/utils/session_controller.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      context.go(session.userId == null ? '/initial' : '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.verde,
      body: Center(
        child: SvgPicture.asset(
          'assets/svg/logo_light.svg',
          width: 900,
          height: 900,
          colorFilter: ColorFilter.mode(
            AppTheme.verdeOscuro,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}