import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataSource {
    final _userCollection = FirebaseFirestore.instance.collection('users');


  Future<bool> AddUserInformation(Map<String, dynamic> userInformation) async {
    try {
      final docRef = _userCollection.doc();
     final userWithMeta = {
        ...userInformation,
        'id': docRef.id,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await docRef.set(userWithMeta);
      return true;
    } catch (e) {
      print('Error adding user information: $e');
      return false;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final query = await _userCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return 'not_found';

      final user = query.docs.first;

      final isActive = user.get('active') == true;
      final savedPassword = user.get('password');

      if (!isActive) return 'inactive';
      if (savedPassword != password) return 'wrong_password';

      return user.id;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

   Future<String?> verifyUserByEmail(String email) async {
    try {
      final query = await _userCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return 'not_found';

      final user = query.docs.first;

      final isActive = user.get('active') == true;

      if (!isActive) return 'inactive';

      return user.id;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<String?> generateRecoveryCode(String email) async {
    try {
      final query = await _userCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return 'not_found';

      final userDoc = query.docs.first;

      final isActive = userDoc.get('active') == true;
      if (!isActive) return 'inactive';

      final code = _generate6DigitCode();
      final expiration = DateTime.now().add(const Duration(minutes: 15));

      await userDoc.reference.update({
        'recoveryCode': code,
        'recoveryExpires': Timestamp.fromDate(expiration),
      });

      return code;
    } catch (e) {
      print('Error generating recovery code: $e');
      return null;
    }
  }

   Future<String?> updateUserPassword(String email,String password) async {
    try {
      final query = await _userCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return 'not_found';

      final userDoc = query.docs.first;

      final isActive = userDoc.get('active') == true;
      if (!isActive) return 'inactive';


      await userDoc.reference.update({
        'password': password,
        'recoveryExpires': '',
        'recoveryCode': '',
      });

      return 'user_updated';
    } catch (e) {
      print('Error generating recovery code: $e');
      return null;
    }
  }

  String _generate6DigitCode() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now % 1000000).toString().padLeft(6, '0');
  }

  Future<bool> verifyResetCode(String email, String code) async {
    try {
      final query = await _userCollection.where('email', isEqualTo: email).limit(1).get();
      if (query.docs.isEmpty) return false;

      final doc = query.docs.first;
      final storedCode = doc.get('recoveryCode');
      final expiry = (doc.get('recoveryExpires') as Timestamp).toDate();

      return storedCode == code && DateTime.now().isBefore(expiry);
    } catch (e) {
      print('Error verificando código: $e');
      return false;
    }
  }


}