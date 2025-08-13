import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_control_gastos_personales/domain/entities/category.dart';

abstract class CategoryDatasource {
  Stream<List<Category>> streamActiveByUser(String uid);
  Future<String> create(Category category);
}

class CategoryDatasourceImpl implements CategoryDatasource {
  final FirebaseFirestore _db;
  CategoryDatasourceImpl(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('categories');

  @override
  Stream<List<Category>> streamActiveByUser(String uid) {
    return _col
        .where('state', isEqualTo: true)
        .where('usercreate', isEqualTo: uid)
        .orderBy('createdate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<String> create(Category category) async {
    final ref = _col.doc();
    final data = {
      'categoryid'     : ref.id,
      'description'    : category.description,
      'state'          : category.state,
      'usercreate'     : category.userCreate,
      'createdate'     : FieldValue.serverTimestamp(),
      'iconCodePoint'  : category.iconCodePoint,
      'iconFontFamily' : category.iconFontFamily,
      'iconFontPackage': category.iconFontPackage,
      'trantypeid'     : category.defaultTypeId,
    };
    await ref.set(data);
    return ref.id;
  }

  
  Category _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Category(
      id: (d['categoryid'] as String?) ?? doc.id,
      description: d['description'] ?? '',
      state: (d['state'] as bool?) ?? true,
      userCreate: d['usercreate'] ?? '',
      createDate: (d['createdate'] is Timestamp)
          ? (d['createdate'] as Timestamp).toDate() : null,
      iconCodePoint: d['iconCodePoint'] ?? 0xe0b0,
      iconFontFamily: d['iconFontFamily'] ?? 'MaterialIcons',
      iconFontPackage: d['iconFontPackage'],
      defaultTypeId: (d['trantypeid'] as int?) ?? 1,
    );
  }
}
