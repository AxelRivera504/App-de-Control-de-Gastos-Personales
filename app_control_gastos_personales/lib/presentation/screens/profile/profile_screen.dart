import 'package:app_control_gastos_personales/application/controllers/category/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/presentation/screens/screens.dart';
import 'package:app_control_gastos_personales/infrastucture/services/auth_service.dart';

import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:app_control_gastos_personales/presentation/widgets/profile_option_item.dart';
import 'package:app_control_gastos_personales/presentation/widgets/user_info_card.dart';
import 'package:app_control_gastos_personales/presentation/widgets/snackbar_mixin.dart';

class ProfileScreen extends StatefulWidget {
  static const name = 'profile-screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SnackBarMixin {
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
      await SessionController.instance.loadSession();
      final sessionUserId = SessionController.instance.userId;
      
      if (sessionUserId == null) {
        _setNoAuthState();
        return;
      }

      final userData = await _authService.getCurrentUserData();
      final currentUserEmail = await _authService.getCurrentUserEmail();
      
      if (userData != null) {
        _setUserDataState(userData, currentUserEmail, sessionUserId);
      } else {
        _setMinimalUserState(sessionUserId, currentUserEmail);
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
      _setErrorState();
    }
  }

  void _setUserDataState(Map<String, dynamic> userData, String? email, String sessionId) {
    setState(() {
      userName = userData['name'] ?? 'Usuario';
      userId = userData['docId'] ?? sessionId;
      userEmail = email ?? '';
      isLoading = false;
    });
  }

  void _setMinimalUserState(String sessionId, String? email) {
    setState(() {
      userName = 'Usuario';
      userId = sessionId;
      userEmail = email ?? '';
      isLoading = false;
    });
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
       // Destruye controladores con estado de usuario anterior
      if (Get.isRegistered<CategoryController>()) {
        Get.delete<CategoryController>(force: true);
      }
      if (mounted) context.go('/initial');
    } catch (e) {
      showSnackBar(context, 'Error al cerrar sesión: $e');
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
            const NavigationHeader(
              title: 'Perfil',
              showNotifications: true,
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
                      UserInfoCard(
                        userName: userName,
                        userId: userId,
                        userEmail: userEmail,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 25),
                      ..._buildProfileOptions(),
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

  List<Widget> _buildProfileOptions() {
    return [
      ProfileOptionItem(
        icon: Icons.person_outline,
        label: 'Editar Perfil',
        onTap: () async {
          final result = await context.pushNamed(EditProfileScreen.name);
          if (result == true) _loadUserData();
        },
      ),
      ProfileOptionItem(
        icon: Icons.security,
        label: 'Términos y Condiciones',
        onTap: () => context.pushNamed('security-screen'),
      ),
      ProfileOptionItem(
        icon: Icons.settings,
        label: 'Configuración',
        onTap: () => context.pushNamed(SettingsScreen.name),
      ),
      ProfileOptionItem(
        icon: Icons.help_outline,
        label: 'Ayuda y Soporte',
        onTap: () => context.pushNamed(HelpCenterScreen.name),
      ),
      ProfileOptionItem(
        icon: Icons.logout,
        label: 'Cerrar Sesión',
        onTap: _showSignOutDialog,
        isDestructive: true,
      ),
    ];
  }
}


