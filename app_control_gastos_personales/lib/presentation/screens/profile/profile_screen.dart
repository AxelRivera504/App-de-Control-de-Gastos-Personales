import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/presentation/screens/screens.dart';
import 'package:app_control_gastos_personales/infrastucture/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  static const name = 'profile-screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  
  String userName = 'Usuario';
  String userId = '----';
  String userEmail = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      print('=== DEBUG ProfileScreen ===');
      
      // Verificar si hay un usuario autenticado
      final hasSession = await _authService.isUserAuthenticated();
      print('1. ¿Hay sesión activa? $hasSession');

      if (!hasSession) {
        setState(() {
          userName = 'No autenticado';
          userId = 'N/A';
          userEmail = '';
          isLoading = false;
        });
        return;
      }

      // Obtener datos del usuario actual
      final userData = await _authService.getCurrentUserData();
      final currentUserEmail = await _authService.getCurrentUserEmail();
      final currentUserId = await _authService.getCurrentUserId();
      
      print('2. UserData: $userData');
      print('3. CurrentEmail: $currentUserEmail');  
      print('4. CurrentUserId: $currentUserId');

      if (userData != null && currentUserEmail != null) {
        setState(() {
          userName = userData['name'] ?? 'Usuario';
          userId = userData['docId'] ?? 'N/A';
          userEmail = currentUserEmail;
          isLoading = false;
        });
      } else {
        setState(() {
          userName = 'Usuario no encontrado';
          userId = 'N/A';
          userEmail = currentUserEmail ?? '';
          isLoading = false;
        });
      }

    } catch (e) {
      print('Error cargando datos del usuario: $e');
      setState(() {
        userName = 'Error al cargar';
        userId = 'Error';
        userEmail = '';
        isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        context.go('/initial');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut();
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
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
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(
                    Icons.arrow_back_ios, 
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Text(
                  'Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.notifications_none, 
                  color: Colors.white,
                  size: 24,
                ),
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
                  
                  // Información del usuario
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
                    // Mostrar email del usuario
                    Text(
                      userEmail,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Mostrar ID del documento
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
                  _buildProfileOption(
                    Icons.person_outline, 
                    'Editar Perfil',
                    onTap: () {
                      // TODO: Implementar edición de perfil
                    },
                  ),
                  
                  _buildProfileOption(
                    Icons.security, 
                    'Términos y Condiciones',
                    onTap: () {
                      context.pushNamed('security-screen');
                    },
                  ),
                  
                  _buildProfileOption(
                    Icons.settings, 
                    'Configuración',
                    onTap: () {
                      context.pushNamed(SettingsScreen.name);
                    },
                  ),
                  
                  _buildProfileOption(
                    Icons.help_outline, 
                    'Ayuda y Soporte',
                    onTap: () {
                      context.pushNamed(HelpCenterScreen.name);
                    },
                  ),

                  _buildProfileOption(
                    Icons.logout, 
                    'Cerrar Sesión',
                    onTap: _showSignOutDialog,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon, 
    String label, {
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive ? Colors.redAccent : AppTheme.verde,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                color: Colors.white, 
                size: 20,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isDestructive ? Colors.redAccent : AppTheme.verdeOscuro,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDestructive ? Colors.redAccent : AppTheme.verdeOscuro,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}



