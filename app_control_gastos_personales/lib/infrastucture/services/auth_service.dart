// Coloca este archivo en: lib/infrastucture/services/auth_service.dart

import 'package:app_control_gastos_personales/infrastucture/datasources/user_datasource.dart';
import 'package:app_control_gastos_personales/infrastucture/services/session_service.dart';

class AuthService {
  final UserDataSource _userDataSource = UserDataSource();
  final SessionService _sessionService = SessionService();

  /// Verifica si hay un usuario con sesión activa
  Future<bool> isUserAuthenticated() async {
    return await _sessionService.hasActiveSession();
  }

  /// Obtiene el ID del usuario actual
  Future<String?> getCurrentUserId() async {
    return await _sessionService.getCurrentUserId();
  }

  /// Obtiene el email del usuario actual
  Future<String?> getCurrentUserEmail() async {
    return await _sessionService.getCurrentUserEmail();
  }

  /// Obtiene los datos completos del usuario actual
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return null;

      // Obtener datos desde Firestore usando el userId
      final userData = await _userDataSource.getUserById(userId);
      return userData;
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

  /// Actualiza el perfil del usuario actual
  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        throw Exception('No hay usuario autenticado.');
      }

      // Preparar datos para actualizar
      Map<String, dynamic> updateData = {};
      
      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }
      
      if (email != null && email.trim().isNotEmpty) {
        updateData['email'] = email.trim();
      }
      
      if (phone != null && phone.trim().isNotEmpty) {
        updateData['phone'] = phone.trim();
      }

      if (updateData.isEmpty) {
        throw Exception('No hay datos para actualizar.');
      }

      // Actualizar en Firestore
      final success = await _userDataSource.updateUserById(userId, updateData);
      
      if (success && updateData.containsKey('name')) {
        // Actualizar nombre en la sesión también
        await _sessionService.updateUserName(updateData['name']);
      }
      
      return success;
    } catch (e) {
      print('Error actualizando perfil: $e');
      rethrow;
    }
  }

  /// Verifica la contraseña del usuario actual
  Future<bool> verifyCurrentUserPassword(String password) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return false;

      return await _userDataSource.verifyPasswordById(userId, password);
    } catch (e) {
      print('Error verificando contraseña: $e');
      return false;
    }
  }

  /// Cambia la contraseña del usuario actual
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        throw Exception('No hay usuario autenticado.');
      }

      // Verificar contraseña actual
      final isValidPassword = await verifyCurrentUserPassword(currentPassword);
      if (!isValidPassword) {
        throw Exception('La contraseña actual es incorrecta.');
      }

      // Validar nueva contraseña
      if (newPassword.length < 6) {
        throw Exception('La nueva contraseña debe tener al menos 6 caracteres.');
      }

      if (currentPassword == newPassword) {
        throw Exception('La nueva contraseña debe ser diferente a la actual.');
      }

      // Cambiar contraseña
      final success = await _userDataSource.changePasswordById(userId, newPassword);
      if (!success) {
        throw Exception('Error al actualizar la contraseña.');
      }

    } catch (e) {
      rethrow;
    }
  }

  /// Elimina la cuenta del usuario actual
  Future<void> deleteAccount(String password) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        throw Exception('No hay usuario autenticado.');
      }

      // Verificar contraseña
      final isValidPassword = await verifyCurrentUserPassword(password);
      if (!isValidPassword) {
        throw Exception('La contraseña es incorrecta.');
      }

      // Eliminar cuenta (soft delete)
      final success = await _userDataSource.deleteUserById(userId);
      if (!success) {
        throw Exception('Error al eliminar la cuenta.');
      }

      // Limpiar sesión
      await _sessionService.clearUserSession();

    } catch (e) {
      rethrow;
    }
  }

  /// Inicia sesión con email y contraseña
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      final result = await _userDataSource.login(email, password);
      
      if (result == null) {
        throw Exception('Error de conexión. Inténtalo de nuevo.');
      }

      switch (result) {
        case 'not_found':
          throw Exception('No existe una cuenta con este correo.');
        case 'inactive':
          throw Exception('Esta cuenta ha sido deshabilitada.');
        case 'wrong_password':
          throw Exception('Contraseña incorrecta.');
        default:
          // Login exitoso, result contiene el userId (docId de Firestore)
          final userData = await _userDataSource.getUserById(result);
          if (userData != null) {
            // Guardar sesión con el docId como userId
            await _sessionService.saveUserSession(
              userId: result, // Este es el docId de Firestore
              email: userData['email'],
              name: userData['name'] ?? 'Usuario',
            );
            return userData;
          }
          throw Exception('Error al obtener datos del usuario.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Registra un nuevo usuario
  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final userInfo = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      };

      final success = await _userDataSource.AddUserInformation(userInfo);
      return success;
    } catch (e) {
      print('Error en registro: $e');
      return false;
    }
  }

  /// Cierra sesión
  Future<void> signOut() async {
    try {
      await _sessionService.clearUserSession();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// Genera código de recuperación
  Future<String?> generateRecoveryCode(String email) async {
    return await _userDataSource.generateRecoveryCode(email);
  }

  /// Verifica código de recuperación
  Future<bool> verifyRecoveryCode(String email, String code) async {
    return await _userDataSource.verifyResetCode(email, code);
  }

  /// Actualiza contraseña con código de recuperación
  Future<String?> resetPassword(String email, String newPassword) async {
    return await _userDataSource.updateUserPassword(email, newPassword);
  }
}