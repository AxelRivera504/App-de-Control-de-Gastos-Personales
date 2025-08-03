import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:go_router/go_router.dart';

class InitialScreen extends StatelessWidget {
  static const name = 'initial-screen';
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDesign(
      header: Column(
        children: const [
          Icon(
            Icons.show_chart_rounded,
            size: 80,
            color: AppTheme.verdeOscuro,
          ),
          SizedBox(height: 10),
          Text(
            'FinZen',
            style: TextStyle(
              color: AppTheme.verdeOscuro,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Controla tus finanzas de forma inteligente',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.blancoPalido, fontSize: 12),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: AppTheme.verde,
              ),
              child: const Center(
                child: Text(
                  'Iniciar Sesión',
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
            onTap: () => context.go('/signup'),
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: AppTheme.verdePalido,
              ),
              child: const Center(
                child: Text(
                  'Registrarse',
                  style: TextStyle(
                    color: AppTheme.verdeOscuro,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          TextButton(
            onPressed: () {},
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: AppTheme.verdeOscuro, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}