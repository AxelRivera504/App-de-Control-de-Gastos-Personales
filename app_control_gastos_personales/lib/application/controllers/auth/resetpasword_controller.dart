import 'package:app_control_gastos_personales/infrastucture/repositories/user_repository_impl.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final _userRepository = UserRepositoryImpl();

  final isLoading = false.obs;

  Future<String?> resetPassword(String email, String newpassword) async {
    isLoading.value = true;
    final result = await _userRepository.resetPassword(email,newpassword);
    isLoading.value = false;
    return result;
  }
}
