import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_control_gastos_personales/domain/entities/transaction.dart';

abstract class TransactionDatasource {
  Future<String> create(TransactionEntity tx);
  Stream<List<TransactionEntity>> watchByCategory({
    required String userId,
    required String categoryId,
  });
}

class TransactionDatasourceImpl implements TransactionDatasource {
  final FirebaseFirestore _db;
  TransactionDatasourceImpl(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('transactions');

  @override
  Future<String> create(TransactionEntity tx) async {
    final ref = _col.doc();
    final data = tx.toMap()..['transactionid'] = ref.id;
    await ref.set(data);
    return ref.id;
  }

   @override
  Stream<List<TransactionEntity>> watchByCategory({
    required String userId,
    required String categoryId,
  }) {
    return _col
        .where('userid', isEqualTo: userId)
        .where('categoryid', isEqualTo: categoryId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final m = d.data();
              return TransactionEntity(
                id: m['transactionid'] ?? d.id,
                userId: m['userid'] ?? '',
                categoryId: m['categoryid'] ?? '',
                trantypeid: (m['trantypeid'] as num?)?.toInt() ?? 2,
                amount: (m['amount'] as num?)?.toDouble() ?? 0,
                date: (m['date'] as Timestamp).toDate(),
                notes: m['notes'],
              );
            }).toList());
  }
}
