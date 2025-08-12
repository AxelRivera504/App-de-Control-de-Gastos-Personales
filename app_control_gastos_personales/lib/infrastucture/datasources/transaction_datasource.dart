import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_control_gastos_personales/domain/entities/transaction.dart';

abstract class TransactionDatasource {
  Future<String> create(TransactionEntity tx);
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
}
