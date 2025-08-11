import 'package:app_control_gastos_personales/infrastructure/repositories/user_repository_impl.dart';
import 'package:get/get.dart';

class VerifyCodeController extends GetxController {
  final _userRepository = UserRepositoryImpl();

  final isLoading = false.obs;
  final isLoadingRecoverCode = false.obs;

  Future<bool> verifyResetCode(String email, String code) async {
    isLoading.value = true;
    final result = await _userRepository.verifyResetCode(email,code);
    isLoading.value = false;
    return result;
  }

  Future<String?> generateRecoveryCode(String email) async {
    isLoadingRecoverCode.value = true;
    final result = await _userRepository.generateRecoveryCode(email);
    isLoadingRecoverCode.value = false;

    if (result != null && result != 'not_found' && result != 'inactive') {
      return result;
    }

    return result;
  }
}
