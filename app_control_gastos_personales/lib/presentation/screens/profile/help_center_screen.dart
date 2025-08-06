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

  final List<String> faqQuestions = [
    'How to use the app?',
    'How much does it cost?',
    'How to contact support?',
    'How can I reset my password?',
    'Are there any privacy or data security measures?',
    'Can I customize settings?',
    'How can I delete my account?',
    'How do I access my expense history?',
    'Can I use the app offline?',
  ];

  final List<Map<String, dynamic>> contactOptions = [
    {'icon': Icons.support_agent, 'label': 'Customer Service'},
    {'icon': Icons.language, 'label': 'Website'},
    {'icon': Icons.facebook, 'label': 'Facebook'},
    {'icon': FontAwesomeIcons.whatsapp, 'label': 'Whatsapp'},
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
          // Encabezado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => context.pop(), // ✅ Navegación hacia atrás
                ),
                const Text(
                  'Help & FAQS',
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

          // Contenido inferior
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
                  // Selector de pestañas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton('FAQ', showFaq, () {
                        setState(() => showFaq = true);
                      }),
                      const SizedBox(width: 8),
                      _buildTabButton('Contact Us', !showFaq, () {
                        setState(() => showFaq = false);
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Lista dinámica según la pestaña
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
      child: ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 2),
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _isExpandedList[index] = !isExpanded;
          });
        },
        children: List.generate(faqQuestions.length, (index) {
          return ExpansionPanel(
            isExpanded: _isExpandedList[index],
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) {
              return ListTile(
                title: Text(
                  faqQuestions[index],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.verdeOscuro,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Esta es una respuesta de ejemplo para "${faqQuestions[index]}". Aquí se explica brevemente lo que el usuario debe saber.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
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
