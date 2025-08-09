import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/presentation/screens/screens.dart';
import 'package:app_control_gastos_personales/infrastucture/services/auth_service.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';

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
      // Cargar sesión desde almacenamiento seguro
      await SessionController.instance.loadSession();
      
      final sessionUserId = SessionController.instance.userId;
      
      if (sessionUserId == null) {
        _setNoAuthState();
        return;
      }

      // Intentar obtener datos del usuario
      final userData = await _authService.getCurrentUserData();
      final currentUserEmail = await _authService.getCurrentUserEmail();
      
      if (userData != null) {
        setState(() {
          userName = userData['name'] ?? 'Usuario';
          userId = userData['docId'] ?? sessionUserId;
          userEmail = currentUserEmail ?? '';
          isLoading = false;
        });
      } else {
        // Si no hay userData pero hay sesión, usar datos mínimos
        setState(() {
          userName = 'Usuario';
          userId = sessionUserId;
          userEmail = currentUserEmail ?? '';
          isLoading = false;
        });
      }

    } catch (e) {
      print('Error cargando datos del usuario: $e');
      _setErrorState();
    }
  }

  void _setNoAuthState() {
    setState(() {
      userName = 'No autenticado';
      userId = 'N/A';
      userEmail = '';
      isLoading = false;
    });
  }

  void _setErrorState() {
    setState(() {
      userName = 'Error al cargar';
      userId = 'Error';
      userEmail = '';
      isLoading = false;
    });
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      SessionController.instance.clearSession();
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
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header con navegación
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
            const SizedBox(height: 20),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.blancoPalido,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Avatar del usuario
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.verde,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      
                      // Información del usuario
                      if (isLoading) ...[
                        const CircularProgressIndicator(
                          color: AppTheme.verde,
                          strokeWidth: 2,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Cargando...',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ] else ...[
                        Text(
                          userName,
                          style: const TextStyle(
                            color: AppTheme.verdeOscuro,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: $userId',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 25),
                      
                      // Opciones del perfil
                      _buildProfileOption(
                        Icons.person_outline, 
                        'Editar Perfil',
                        onTap: () {
                          context.pushNamed(EditProfileScreen.name);
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
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: isDestructive ? Colors.redAccent : AppTheme.verde,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                color: Colors.white, 
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: isDestructive ? Colors.redAccent : AppTheme.verdeOscuro,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDestructive ? Colors.redAccent : AppTheme.verdeOscuro,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}


