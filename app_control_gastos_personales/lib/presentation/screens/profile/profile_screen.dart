import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/presentation/screens/screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  static const name = 'profile-screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Usuario';
  String userId = '----';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    try {
      String? userEmail = await _getCurrentUserEmail();
      
      if (userEmail == null) {
        print('Error: No se pudo obtener el email del usuario');
        setState(() {
          userName = 'Error al cargar';
          userId = 'Error';
          isLoading = false;
        });
        return;
      }
      // Buscar el documento del usuario en Firebase
      final userCollection = FirebaseFirestore.instance.collection('users');
      final query = await userCollection
          .where('email', isEqualTo: userEmail)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final userDoc = query.docs.first;
        final userData = userDoc.data();
        
        setState(() {
          userName = userData['name'] ?? 'Usuario';
          userId = userDoc.id;
          isLoading = false;
        });
      } else {
        setState(() {
          userName = 'Usuario no encontrado';
          userId = 'N/A';
          isLoading = false;
        });
      }

    } catch (e) {
      print('Error cargando datos del usuario: $e');
      setState(() {
        userName = 'Error al cargar';
        userId = 'Error';
        isLoading = false;
      });
    }
  }

  Future<String?> _getCurrentUserEmail() async {
    return 'axeldm05@gmail.com'; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.verde,
      body: Column(
        children: [
          const SizedBox(height: 60),
          // Header con navegación y título
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
                  
                  // Avatar del usuario
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.verde,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  
                  // Información del usuario (nombre e ID)
                  if (isLoading) ...[
                    const CircularProgressIndicator(
                      color: AppTheme.verde,
                      strokeWidth: 2,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Cargando...',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ] else ...[
                    // Mostrar nombre del usuario
                    Text(
                      userName,
                      style: const TextStyle(
                        color: AppTheme.verdeOscuro,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Mostrar ID del usuario
                    Text(
                      'ID: $userId',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 30),
                  
                  // Opciones del perfil
                  _buildProfileOption(Icons.person_outline, 'Editar Perfil'),
                  
                  GestureDetector(
                    onTap: () {
                      context.pushNamed('security-screen');
                    },
                    child: _buildProfileOption(Icons.security, 'Términos y Condiciones'),
                  ),
                  
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(SettingsScreen.name);
                    },
                    child: _buildProfileOption(Icons.settings, 'Configuración'),
                  ),
                  
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(HelpCenterScreen.name);
                    },
                    child: _buildProfileOption(Icons.help_outline, 'Ayuda y Soporte'),
                  ),

                  GestureDetector(
                    onTap: () {
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


