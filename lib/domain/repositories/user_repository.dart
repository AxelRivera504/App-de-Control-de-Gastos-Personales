import '../entities/user.dart';

abstract class UserRepository {
  Future<String?> login(String email, String password);
  Future<bool> register(User user);
  Future<String?> verifyUserByEmail(String email);
  Future<String?> generateRecoveryCode(String email);
  Future<bool> verifyResetCode(String email, String code);
  Future<String?> resetPassword(String email, String newpassword);

}
