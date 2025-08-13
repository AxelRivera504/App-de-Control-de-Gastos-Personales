import 'package:app_control_gastos_personales/domain/entities/transaction.dart';
import 'package:app_control_gastos_personales/domain/repositories/transaction_repository.dart';
import 'package:app_control_gastos_personales/infrastucture/datasources/transaction_datasource.dart';
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDatasource datasource;
  TransactionRepositoryImpl(this.datasource);

  @override
  Future<String> create(TransactionEntity tx) => datasource.create(tx);

   @override
  Stream<List<TransactionEntity>> watchByCategory({required String userId, required String categoryId}) =>
      datasource.watchByCategory(userId: userId, categoryId: categoryId);
}

