import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await user.delete();
      } else {
        throw Exception('No hay usuario autenticado.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'Por seguridad, vuelve a iniciar sesion para eliminar tu cuenta.',
        );
      } else {
        throw Exception('Error al eliminar la cuenta: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
