import 'package:app_control_gastos_personales/infrastructure/repositories/user_repository_impl.dart';
import 'package:app_control_gastos_personales/infrastructure/services/auth_service.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final _userRepository = UserRepositoryImpl();
  final _authService = AuthService(); 

  final isLoading = false.obs;

  Future<String?> login(String email, String password) async {
    isLoading.value = true;
    
    try {
 
      final userData = await _authService.signIn(email, password);
      
      if (userData != null) {

        final session = SessionController.instance;
        session.setSession(
          userData['docId'] ?? userData['id'] ?? 'unknown', 
          "fake-token", 
          DateTime.now().add(Duration(hours: 1))
        );
        
        isLoading.value = false;
        return userData['docId'] ?? userData['id'];
      }
      
      isLoading.value = false;
      return 'login_failed';
      
    } catch (e) {
      isLoading.value = false;
      
      final errorMessage = e.toString();
      
      if (errorMessage.contains('No existe una cuenta')) {
        return 'not_found';
      } else if (errorMessage.contains('deshabilitada')) {
        return 'inactive';
      } else if (errorMessage.contains('Contraseña incorrecta')) {
        return 'wrong_password';
      }
      
      return null; 
    }
  }
}
