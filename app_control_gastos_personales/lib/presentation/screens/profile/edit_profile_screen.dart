import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/infrastucture/services/auth_service.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';

class EditProfileScreen extends StatefulWidget {
  static const String name = 'edit-profile-screen';

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Variables para almacenar datos originales
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
        _showSnackBar('Error: No se encontró sesión activa');
        return;
      }

      final userData = await _authService.getCurrentUserData();
      final currentUserEmail = await _authService.getCurrentUserEmail();
      
      if (userData != null) {
        setState(() {
          _originalName = userData['name'] ?? '';
          _originalPhone = userData['phone'] ?? '';
          _originalEmail = currentUserEmail ?? '';
          _userId = userData['docId'] ?? sessionUserId;
          _isLoadingData = false;
        });
      } else {
        setState(() {
          _originalName = '';
          _originalPhone = '';
          _originalEmail = currentUserEmail ?? '';
          _userId = sessionUserId;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
      setState(() {
        _isLoadingData = false;
      });
      _showSnackBar('Error al cargar los datos del usuario');
    }
  }

  String? _validateName(String? value) {
    // Solo validar si el usuario escribió algo
    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    // Solo validar si el usuario escribió algo
    if (value != null && value.trim().isNotEmpty && !value.contains('@')) {
      return 'Correo inválido';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    // Solo validar si el usuario escribió algo
    if (value != null && value.trim().isNotEmpty && value.trim().length < 8) {
      return 'Número telefónico inválido';
    }
    return null;
  }

  bool _hasChanges() {
    final nameChanged = _nameController.text.trim().isNotEmpty && 
                       _nameController.text.trim() != _originalName;
    final emailChanged = _emailController.text.trim().isNotEmpty && 
                        _emailController.text.trim() != _originalEmail;
    final phoneChanged = _phoneController.text.trim().isNotEmpty && 
                        _phoneController.text.trim() != _originalPhone;
    
    return nameChanged || emailChanged || phoneChanged;
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
              context.pop(); // Regresar a ProfileScreen
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
      // Preparar solo los datos que cambiaron
      String? newName;
      String? newEmail;
      String? newPhone;
      
      if (_nameController.text.trim().isNotEmpty && _nameController.text.trim() != _originalName) {
        newName = _nameController.text.trim();
      }
      if (_emailController.text.trim().isNotEmpty && _emailController.text.trim() != _originalEmail) {
        newEmail = _emailController.text.trim();
      }
      if (_phoneController.text.trim().isNotEmpty && _phoneController.text.trim() != _originalPhone) {
        newPhone = _phoneController.text.trim();
      }

      // Actualizar en Firebase
      final success = await _authService.updateUserProfile(
        name: newName,
        email: newEmail,
        phone: newPhone,
      );

      if (success) {
        // Actualizar datos locales para reflejar cambios inmediatamente
        setState(() {
          if (newName != null) _originalName = newName;
          if (newEmail != null) _originalEmail = newEmail;
          if (newPhone != null) _originalPhone = newPhone;
          
          // Limpiar los controllers para mostrar placeholders actualizados
          _nameController.clear();
          _emailController.clear();
          _phoneController.clear();
        });

        _showSnackBar('Perfil actualizado correctamente');
        
        if (mounted) {
          // Pasar true para indicar que hubo cambios
          context.pop(true);
        }
      } else {
        _showSnackBar('Error al actualizar el perfil');
      }
    } catch (e) {
      _showSnackBar('Error al actualizar el perfil: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('correctamente') 
              ? AppTheme.verde 
              : Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.verde,
      resizeToAvoidBottomInset: false, // Evita que se redimensione con el teclado
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
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
                    'Editar Perfil',
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
                child: _isLoadingData 
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.verde,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              
                              // Avatar del usuario
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: AppTheme.verde,
                                child: Icon(
                                  Icons.person, 
                                  size: 50, 
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              Text(
                                _originalName.isNotEmpty ? _originalName : 'Usuario',
                                style: const TextStyle(
                                  color: AppTheme.verdeOscuro,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'ID: $_userId',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11,
                                ),
                              ),
                              
                              const SizedBox(height: 25),
                              
                              // Título Account Settings
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

                              // Campo Nombre
                              _buildInputField(
                                label: 'Nombre de Usuario',
                                controller: _nameController,
                                placeholder: _originalName,
                                validator: _validateName,
                              ),
                              const SizedBox(height: 15),

                              // Campo Teléfono
                              _buildInputField(
                                label: 'Teléfono',
                                controller: _phoneController,
                                placeholder: _originalPhone,
                                validator: _validatePhone,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 15),

                              // Campo Email
                              _buildInputField(
                                label: 'Correo Electrónico',
                                controller: _emailController,
                                placeholder: _originalEmail,
                                validator: _validateEmail,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              
                              const SizedBox(height: 40),

                              // Botón Actualizar Perfil - Fijo sin Spacer
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.verde,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'Actualizar Perfil',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.verdeOscuro,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.verdePalido,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.verdePalido,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            style: const TextStyle(
              color: AppTheme.verdeOscuro,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}