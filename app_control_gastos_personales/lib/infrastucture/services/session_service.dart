import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para manejar la sesión del usuario actual
class SessionService {
  static const String _userIdKey = 'current_user_id';
  static const String _userEmailKey = 'current_user_email';
  static const String _userNameKey = 'current_user_name';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Guarda la sesión del usuario actual
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userNameKey, name);
  }

  /// Obtiene el ID del usuario actual
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Obtiene el email del usuario actual
  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Obtiene el nombre del usuario actual
  Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Verifica si hay una sesión activa
  Future<bool> hasActiveSession() async {
    final userId = await getCurrentUserId();
    return userId != null && userId.isNotEmpty;
  }

  /// Obtiene los datos completos del usuario actual desde Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['docId'] = doc.id; // El ID del documento
      return data;
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

  /// Verifica si los datos de la sesión siguen siendo válidos
  Future<bool> validateCurrentSession() async {
    try {
      final userData = await getCurrentUserData();
      return userData != null && userData['active'] == true;
    } catch (e) {
      print('Error validando sesión: $e');
      return false;
    }
  }

  /// Limpia la sesión del usuario
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
  }

  /// Actualiza el nombre del usuario en la sesión
  Future<void> updateUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, newName);
  }
}