import 'package:app_control_gastos_personales/infrastucture/repositories/user_repository_impl.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  final _userRepository = UserRepositoryImpl();

  final isLoading = false.obs;

  Future<String?> verifyUserByEmail(String email) async {
    isLoading.value = true;
    final result = await _userRepository.verifyUserByEmail(email);
    isLoading.value = false;

    if (result != null && result != 'not_found' && result != 'inactive' && result != 'wrong_password') {
      await _userRepository.generateRecoveryCode(email);
    }

    return result;
  }
}
