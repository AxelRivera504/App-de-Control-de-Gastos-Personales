import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';

class SecurityScreen extends StatelessWidget {
  static const String name = 'security-screen';
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.verde,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  const Text(
                    'Seguridad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.lock_outline, color: Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Política de Privacidad y Seguridad',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.verdeOscuro,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'En FinZen nos tomamos muy en serio la privacidad y seguridad de tus datos personales. Esta política explica cómo recopilamos, usamos y protegemos tu información.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '1. Recopilación de Información',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Recopilamos información personal como tu nombre, correo electrónico, número de teléfono, e historial de transacciones financieras para brindarte una mejor experiencia.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '2. Uso de la Información',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'La información recopilada se utiliza para personalizar el contenido, mejorar nuestros servicios, y garantizar la seguridad de tu cuenta.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '3. Seguridad de los Datos',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Aplicamos medidas de seguridad físicas, electrónicas y administrativas para proteger tu información personal contra accesos no autorizados.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '4. Compartición de Datos',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'No compartimos tu información personal con terceros, excepto cuando sea necesario por ley o para proveer nuestros servicios con tu consentimiento explícito.',
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Para más información, visita nuestra política completa en:',
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                        },
                        child: const Text(
                          'www.finwiseapp.de',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.verde,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => context.pop(),
                          child: const Text(
                            'Volver al perfil',
                            style: TextStyle(
                              color: AppTheme.verdeOscuro,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
