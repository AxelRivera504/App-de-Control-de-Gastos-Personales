import 'package:app_control_gastos_personales/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<String> create(TransactionEntity tx);
  Stream<List<TransactionEntity>> watchByCategory({required String userId, required String categoryId});
}