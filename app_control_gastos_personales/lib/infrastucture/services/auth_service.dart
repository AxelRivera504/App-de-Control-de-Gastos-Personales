import 'package:app_control_gastos_personales/infrastucture/datasources/user_datasource.dart';
import 'package:app_control_gastos_personales/infrastucture/services/session_service.dart';

class AuthService {
  final UserDataSource _userDataSource = UserDataSource();
  final SessionService _sessionService = SessionService();

  Future<bool> isUserAuthenticated() async {
    return await _sessionService.hasActiveSession();
  }
  Future<String?> getCurrentUserId() async {
    return await _sessionService.getCurrentUserId();
  }
  Future<String?> getCurrentUserEmail() async {
    return await _sessionService.getCurrentUserEmail();
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return null;

      final userData = await _userDataSource.getUserById(userId);
      return userData;
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

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

      final success = await _userDataSource.updateUserById(userId, updateData);
      
      if (success && updateData.containsKey('name')) {
        await _sessionService.updateUserName(updateData['name']);
      }
      
      return success;
    } catch (e) {
      print('Error actualizando perfil: $e');
      rethrow;
    }
  }

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

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        throw Exception('No hay usuario autenticado.');
      }

      final isValidPassword = await verifyCurrentUserPassword(currentPassword);
      if (!isValidPassword) {
        throw Exception('La contraseña actual es incorrecta.');
      }

      if (newPassword.length < 6) {
        throw Exception('La nueva contraseña debe tener al menos 6 caracteres.');
      }

      if (currentPassword == newPassword) {
        throw Exception('La nueva contraseña debe ser diferente a la actual.');
      }

      final success = await _userDataSource.changePasswordById(userId, newPassword);
      if (!success) {
        throw Exception('Error al actualizar la contraseña.');
      }

    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        throw Exception('No hay usuario autenticado.');
      }

      final isValidPassword = await verifyCurrentUserPassword(password);
      if (!isValidPassword) {
        throw Exception('La contraseña es incorrecta.');
      }

      final success = await _userDataSource.deleteUserById(userId);
      if (!success) {
        throw Exception('Error al eliminar la cuenta.');
      }

      await _sessionService.clearUserSession();

    } catch (e) {
      rethrow;
    }
  }

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

          final userData = await _userDataSource.getUserById(result);
          if (userData != null) {
            await _sessionService.saveUserSession(
              userId: result, 
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

  Future<void> signOut() async {
    try {
      await _sessionService.clearUserSession();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  Future<String?> generateRecoveryCode(String email) async {
    return await _userDataSource.generateRecoveryCode(email);
  }

  Future<bool> verifyRecoveryCode(String email, String code) async {
    return await _userDataSource.verifyResetCode(email, code);
  }

  Future<String?> resetPassword(String email, String newPassword) async {
    return await _userDataSource.updateUserPassword(email, newPassword);
  }
}