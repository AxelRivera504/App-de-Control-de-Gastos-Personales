import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/presentation/screens/screens.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';


class ProfileScreen extends StatelessWidget {
  static const name = 'profile-screen';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.verde,
      child: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(Icons.arrow_back_ios, color: Colors.white),
                Text(
                  'Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.notifications_none, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 30),
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
                  const SizedBox(height: 30),
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.verde,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Estudiante',
                    style: TextStyle(
                      color: AppTheme.verdeOscuro,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'ID: 1234',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildProfileOption(Icons.person_outline, 'Editar Perfil'),
                  GestureDetector(
                    onTap: () {
                      context.pushNamed('security-screen');
                    },
                    child: _buildProfileOption(Icons.security, 'Terminos y Condiciones'),
                  ),
                  _buildProfileOption(Icons.settings, 'Configuración'),
                  GestureDetector(
                  onTap: () {
                  context.pushNamed(HelpCenterScreen.name);
                  },
                  child: _buildProfileOption(Icons.help_outline, 'Ayuda y Soporte'),
                ),

                  GestureDetector(
                    onTap: () {
                      SessionController.instance.clearSession();
                      context.go('/initial');
                    },
                    child: _buildProfileOption(Icons.logout, 'Cerrar Sesión'),
      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 20),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.verdeOscuro,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


