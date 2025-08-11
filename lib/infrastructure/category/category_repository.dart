import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_control_gastos_personales/domain/category/category.dart';

class CategoryRepository {
  final _firestore = FirebaseFirestore.instance;
  final String collectionName = 'categories';

  Stream<List<Category>> getCategoriesByUser(String userId) {
    return _firestore
        .collection(collectionName)
        .where('usercreate', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Category.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> addCategory(Category category) async {
    await _firestore.collection(collectionName).add(category.toMap());
  }

  Future<void> updateCategory(String id, Category category) async {
    await _firestore.collection(collectionName).doc(id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
  }
}
