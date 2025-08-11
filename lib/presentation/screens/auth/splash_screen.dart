import 'package:app_control_gastos_personales/utils/session_controller.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Cargar sesion desde almacenamiento seguro
    await SessionController.instance.loadSession();
    
    // Esperar 2 segundos para mostrar splash
    await Future.delayed(const Duration(seconds: 2));
    
    // Navegar segun estado de sesión
    final hasSession = SessionController.instance.userId != null;
    if (mounted) {
      context.go(hasSession ? '/main' : '/initial');
    }
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