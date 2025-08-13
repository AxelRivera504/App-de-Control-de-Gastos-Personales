import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/infrastucture/services/auth_service.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';

import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:app_control_gastos_personales/presentation/widgets/user_info_card.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custom_input_fieldV.dart';
import 'package:app_control_gastos_personales/presentation/widgets/primary_button.dart';
import 'package:app_control_gastos_personales/presentation/widgets/custom_snackbar_mixin.dart';

class EditProfileScreen extends StatefulWidget {
  static const String name = 'edit-profile-screen';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with CustomSnackBarMixin {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _originalName = '';
  String _originalEmail = '';
  String _originalPhone = '';
  String _userId = '';

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      await SessionController.instance.loadSession();
      final sessionUserId = SessionController.instance.userId;
      
      if (sessionUserId == null) {
        showCustomSnackBar(context, 'Error: No se encontró sesión activa');
        return;
      }

      final userData = await _authService.getCurrentUserData();
      final currentUserEmail = await _authService.getCurrentUserEmail();
      
      _setUserData(userData, currentUserEmail, sessionUserId);
    } catch (e) {
      print('Error cargando datos del usuario: $e');
      setState(() => _isLoadingData = false);
      showCustomSnackBar(context, 'Error al cargar los datos del usuario');
    }
  }

  void _setUserData(Map<String, dynamic>? userData, String? email, String sessionId) {
    setState(() {
      if (userData != null) {
        _originalName = userData['name'] ?? '';
        _originalPhone = userData['phone'] ?? '';
        _userId = userData['docId'] ?? sessionId;
      } else {
        _originalName = '';
        _originalPhone = '';
        _userId = sessionId;
      }
      _originalEmail = email ?? '';
      _isLoadingData = false;
    });
  }

  String? _validateName(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.trim().isNotEmpty && !value.contains('@')) {
      return 'Correo inválido';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 8) {
      return 'Número telefónico inválido';
    }
    return null;
  }

  bool _hasChanges() {
    return (_nameController.text.trim().isNotEmpty && _nameController.text.trim() != _originalName) ||
           (_emailController.text.trim().isNotEmpty && _emailController.text.trim() != _originalEmail) ||
           (_phoneController.text.trim().isNotEmpty && _phoneController.text.trim() != _originalPhone);
  }

  void _showNoChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sin Cambios'),
        content: const Text('No se detectaron cambios en la información.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Aceptar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasChanges()) {
      _showNoChangesDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updates = _getUpdateData();
      final success = await _authService.updateUserProfile(
        name: updates['name'],
        email: updates['email'],
        phone: updates['phone'],
      );

      if (success) {
        _updateLocalData(updates);
        showCustomSnackBar(context, 'Perfil actualizado correctamente', isSuccess: true);
        
        if (mounted) context.pop(true);
      } else {
        showCustomSnackBar(context, 'Error al actualizar el perfil');
      }
    } catch (e) {
      showCustomSnackBar(context, 'Error al actualizar el perfil: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, String?> _getUpdateData() {
    return {
      'name': _nameController.text.trim().isNotEmpty && _nameController.text.trim() != _originalName 
          ? _nameController.text.trim() : null,
      'email': _emailController.text.trim().isNotEmpty && _emailController.text.trim() != _originalEmail 
          ? _emailController.text.trim() : null,
      'phone': _phoneController.text.trim().isNotEmpty && _phoneController.text.trim() != _originalPhone 
          ? _phoneController.text.trim() : null,
    };
  }

  void _updateLocalData(Map<String, String?> updates) {
    setState(() {
      if (updates['name'] != null) _originalName = updates['name']!;
      if (updates['email'] != null) _originalEmail = updates['email']!;
      if (updates['phone'] != null) _originalPhone = updates['phone']!;
      
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.verde,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const NavigationHeader(
              title: 'Editar Perfil',
              showNotifications: false,
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
                child: _isLoadingData 
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.verde),
                      )
                    : _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            UserInfoCard(
              userName: _originalName.isNotEmpty ? _originalName : 'Usuario',
              userId: _userId,
              userEmail: _originalEmail,
              isLoading: false,
            ),
            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Configuración de Cuenta',
                style: TextStyle(
                  color: AppTheme.verdeOscuro,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            CustomInputFieldV2(
              label: 'Nombre de Usuario',
              controller: _nameController,
              placeholder: _originalName,
              validator: _validateName,
            ),
            const SizedBox(height: 15),
            CustomInputFieldV2(
              label: 'Teléfono',
              controller: _phoneController,
              placeholder: _originalPhone,
              validator: _validatePhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            CustomInputFieldV2(
              label: 'Correo Electrónico',
              controller: _emailController,
              placeholder: _originalEmail,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: 'Actualizar Perfil',
              isLoading: _isLoading,
              onPressed: _updateProfile,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}