import 'package:get/get.dart';
import 'package:app_control_gastos_personales/infrastructure/datasources/user_datasource.dart';

class RegisterController extends GetxController {
  final isLoading = false.obs;

  Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final userRepository = UserDataSource();
      final result = await userRepository.AddUserInformation({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      return result;
    } catch (e) {
      print('Error en registro: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
