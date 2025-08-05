import 'package:app_control_gastos_personales/infrastucture/repositories/user_repository_impl.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final _userRepository = UserRepositoryImpl();

  final isLoading = false.obs;

  Future<String?> login(String email, String password) async {
    isLoading.value = true;
    final result = await _userRepository.login(email, password);
    isLoading.value = false;

    if (result != null && result != 'not_found' && result != 'inactive' && result != 'wrong_password') {
      final session = SessionController.instance;
      session.setSession(result, "fake-token", DateTime.now().add(Duration(hours: 1)));
    }

    return result;
  }
}
