import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';

import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:app_control_gastos_personales/presentation/widgets/expandable_faq_item.dart';
import 'package:app_control_gastos_personales/presentation/widgets/contact_option_item.dart';
import 'package:app_control_gastos_personales/presentation/widgets/tab_button.dart';

class HelpCenterScreen extends StatefulWidget {
  static const name = 'help-center-screen';
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  bool showFaq = true;

  static const List<Map<String, String>> _faqData = [
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

  static const List<Map<String, dynamic>> _contactOptions = [
    {'icon': Icons.support_agent, 'label': 'Servicio al Cliente'},
    {'icon': Icons.language, 'label': 'Sitio Web'},
    {'icon': Icons.facebook, 'label': 'Facebook'},
    {'icon': FontAwesomeIcons.whatsapp, 'label': 'WhatsApp'},
    {'icon': Icons.camera_alt, 'label': 'Instagram'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.verde,
      body: Column(
        children: [
          const SizedBox(height: 50),
          const NavigationHeader(
            title: 'Centro de Ayuda',
            showNotifications: true,
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
                  _buildTabRow(),
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

  Widget _buildTabRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TabButton(
          label: 'Preguntas Frecuentes',
          isSelected: showFaq,
          onTap: () => setState(() => showFaq = true),
        ),
        const SizedBox(width: 8),
        TabButton(
          label: 'Contáctanos',
          isSelected: !showFaq,
          onTap: () => setState(() => showFaq = false),
        ),
      ],
    );
  }

  Widget _buildFaqList() {
    return SingleChildScrollView(
      child: Column(
        children: _faqData.map((faq) => ExpandableFaqItem(
          question: faq['question']!,
          answer: faq['answer']!,
        )).toList(),
      ),
    );
  }

  Widget _buildContactList() {
    return ListView.separated(
      itemCount: _contactOptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final option = _contactOptions[index];
        return ContactOptionItem(
          icon: option['icon'],
          label: option['label'],
          onTap: () {
            // Implementar contactos
          },
        );
      },
    );
  }
}
