import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InitialScreen extends StatelessWidget {
  static const name = 'initial-screen';
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Parte superior verde
          Container(
            height: size.height,
            color: AppTheme.verde,
          ),

          // Parte inferior blanca con curva
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.42,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Boton Iniciar Sesión
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Container(
                        height: 50,
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

                    // Boton Registrarse
                    GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: Container(
                        height: 50,
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
                    const SizedBox(height: 25),
                    TextButton(
                      onPressed: () {
                        context.go('/forgetpassword');
                      },
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: AppTheme.verdeOscuro,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 60, 
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 400,
                  height: 400,
                  child: SvgPicture.asset(
                    'assets/svg/logo_light.svg',
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.verdeOscuro,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Título
                const Text(
                  'FinZen',
                  style: TextStyle(
                    color: AppTheme.verdeOscuro,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),

                // Subtítulo
                const Text(
                  'Controla tus finanzas de forma inteligente',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}






