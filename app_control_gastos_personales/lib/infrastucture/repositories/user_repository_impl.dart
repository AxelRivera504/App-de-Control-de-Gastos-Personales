import 'package:app_control_gastos_personales/domain/entities/user.dart';
import 'package:app_control_gastos_personales/domain/repositories/user_repository.dart';
import 'package:app_control_gastos_personales/infrastucture/datasources/user_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final _remote = UserDataSource();

  @override
  Future<String?> login(String email, String password) {
    return _remote.login(email, password);
  }

  @override
  Future<bool> register(User user) {
    return _remote.AddUserInformation({
      'email': user.email,
      'password': user.password,
      'name': user.name,
      'phone': user.phone,
    });
  }

  @override
  Future<String?> verifyUserByEmail(String email) {
    return _remote.verifyUserByEmail(email);
  }

  @override
  Future<String?> generateRecoveryCode(String email) {
    return _remote.generateRecoveryCode(email);
  }

}
