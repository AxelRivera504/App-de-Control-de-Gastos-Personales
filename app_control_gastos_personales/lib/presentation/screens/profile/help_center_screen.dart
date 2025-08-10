import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class HelpCenterScreen extends StatefulWidget {
  static const name = 'help-center-screen';
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  bool showFaq = true;

  final List<Map<String, String>> faqData = [
    {
      'question': '¿Cómo usar la aplicación?',
      'answer': 'Para usar la aplicación, primero regístrate con tu email y contraseña. Luego podrás agregar tus gastos diarios, categorizarlos y ver reportes detallados de tus finanzas personales.'
    },
    {
      'question': '¿Cuánto cuesta?',
      'answer': 'La aplicación es completamente gratuita para uso básico. Ofrecemos funciones premium por una suscripción mensual de \$4.99 que incluye reportes avanzados y sincronización en la nube.'
    },
    {
      'question': '¿Cómo contactar al soporte?',
      'answer': 'Puedes contactarnos a través de la pestaña "Contáctanos" en esta misma pantalla, por email a soporte@gastos.com, o por WhatsApp al +1234567890.'
    },
    {
      'question': '¿Cómo puedo restablecer mi contraseña?',
      'answer': 'En la pantalla de inicio de sesión, toca "¿Olvidaste tu contraseña?" e ingresa tu email. Te enviaremos un enlace para crear una nueva contraseña.'
    },
    {
      'question': '¿Qué medidas de privacidad y seguridad existen?',
      'answer': 'Todos tus datos están encriptados y protegidos. No compartimos información personal con terceros y cumplimos con todas las regulaciones de privacidad internacionales.'
    },
    {
      'question': '¿Puedo personalizar la configuración?',
      'answer': 'Sí, puedes personalizar categorías de gastos, establecer presupuestos mensuales, cambiar la moneda predeterminada y configurar notificaciones desde el menú de configuración.'
    },
    {
      'question': '¿Cómo puedo eliminar mi cuenta?',
      'answer': 'Ve a Configuración > Cuenta > Eliminar Cuenta. Ten en cuenta que esta acción es irreversible y todos tus datos se eliminarán permanentemente.'
    },
    {
      'question': '¿Cómo accedo a mi historial de gastos?',
      'answer': 'Desde la pantalla principal, toca el ícono de historial o ve a la pestaña "Reportes" donde podrás ver todos tus gastos organizados por fecha, categoría y monto.'
    },
    {
      'question': '¿Puedo usar la aplicación sin conexión?',
      'answer': 'Sí, puedes registrar gastos sin conexión. Los datos se sincronizarán automáticamente cuando tengas conexión a internet nuevamente.'
    },
  ];

  final List<Map<String, dynamic>> contactOptions = [
    {'icon': Icons.support_agent, 'label': 'Servicio al Cliente'},
    {'icon': Icons.language, 'label': 'Sitio Web'},
    {'icon': Icons.facebook, 'label': 'Facebook'},
    {'icon': FontAwesomeIcons.whatsapp, 'label': 'WhatsApp'},
    {'icon': Icons.camera_alt, 'label': 'Instagram'},
  ];

  final List<bool> _isExpandedList = List.filled(9, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.verde,
      body: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                const Text(
                  'Centro de Ayuda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.notifications_none, color: Colors.white),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.blancoPalido,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(48),
                  topRight: Radius.circular(48),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton('Preguntas Frecuentes', showFaq, () {
                        setState(() => showFaq = true);
                      }),
                      const SizedBox(width: 8),
                      _buildTabButton('Contáctanos', !showFaq, () {
                        setState(() => showFaq = false);
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: showFaq ? _buildFaqList() : _buildContactList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.verde : AppTheme.verdePalido,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.verdeOscuro,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(faqData.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                // Pregunta (header clickeable)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedList[index] = !_isExpandedList[index];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: _isExpandedList[index] ? AppTheme.verdePalido.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            faqData[index]['question']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.verdeOscuro,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isExpandedList[index] ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppTheme.verdeOscuro,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Respuesta (expandible)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isExpandedList[index] ? null : 0,
                  child: _isExpandedList[index]
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppTheme.verdePalido, width: 1),
                            ),
                          ),
                          child: Text(
                            faqData[index]['answer']!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContactList() {
    return ListView.separated(
      itemCount: contactOptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = contactOptions[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.verdePalido,
                child: Icon(item['icon'], color: AppTheme.verdeOscuro),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item['label'],
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.verdeOscuro,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: AppTheme.verdeOscuro),
            ],
          ),
        );
      },
    );
  }
}

