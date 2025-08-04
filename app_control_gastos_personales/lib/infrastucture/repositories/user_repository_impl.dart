import 'package:app_control_gastos_personales/domain/repositories/user_repository.dart';
import 'package:app_control_gastos_personales/infrastucture/datasources/user_datasource.dart';

class UserRepositoryImpl extends UserRepository {
  final UserDataSource userDataSource;

  UserRepositoryImpl(this.userDataSource);

  @override
  Future<bool> addUserInformation(Map<String, dynamic> userInformation) {
    return userDataSource.AddUserInformation(userInformation);
  }
}