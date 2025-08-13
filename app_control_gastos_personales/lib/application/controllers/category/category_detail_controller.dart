import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_control_gastos_personales/domain/entities/transaction.dart';
import 'package:app_control_gastos_personales/infrastucture/datasources/transaction_datasource.dart';
import 'package:app_control_gastos_personales/infrastucture/repositories/transaction_repository_impl.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';

class MonthGroup {
  final String key;             // "2025-08"
  final String label;           // "Agosto 2025"
  final List<TransactionEntity> items;
  final double total;           // suma del mes (según signo)

  MonthGroup({required this.key, required this.label, required this.items, required this.total});
}

class CategoryDetailController extends GetxController {
  CategoryDetailController({required this.categoryId, required this.defaultTypeId});

  final String categoryId;
  final int defaultTypeId; // 1 ingreso, 2 egreso

  final isLoading = true.obs;
  final groups = <MonthGroup>[].obs;

  final totalIncome  = 0.0.obs;
  final totalExpense = 0.0.obs;

  final _ds = TransactionDatasourceImpl(FirebaseFirestore.instance);
  late final _repo = TransactionRepositoryImpl(_ds);
  StreamSubscription<List<TransactionEntity>>? _sub;

  static const _months = [
    'Enero','Febrero','Marzo','Abril','Mayo','Junio',
    'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
  ];

  @override
  Future<void> onInit() async {
    super.onInit();
    await SessionController.instance.loadSession();
    final uid = SessionController.instance.userId;
    if (uid == null || uid.isEmpty) {
      isLoading.value = false;
      return;
    }

    _sub = _repo.watchByCategory(userId: uid, categoryId: categoryId).listen((list) {
      double inc = 0, exp = 0;
      for (final t in list) {
        if (t.trantypeid == 1) {
          inc += t.amount;
        } else {
          exp += t.amount;
        }
      }
      totalIncome.value  = inc;
      totalExpense.value = exp;

      final map = <String, List<TransactionEntity>>{};
      for (final tx in list) {
        final k = '${tx.date.year}-${tx.date.month.toString().padLeft(2,'0')}';
        map.putIfAbsent(k, () => []).add(tx);
      }

      final result = <MonthGroup>[];
      map.entries.toList()
        ..sort((a,b) => b.key.compareTo(a.key))
        ..forEach((e) {
          final year  = int.parse(e.key.split('-')[0]);
          final month = int.parse(e.key.split('-')[1]);
          final label = '${_months[month-1]} $year';

          double tot = 0;
          for (final t in e.value) {
            final sign = (t.trantypeid == 1) ? 1 : -1;
            tot += sign * t.amount;
          }

          result.add(MonthGroup(key: e.key, label: label, items: e.value, total: tot));
        });

      groups.assignAll(result);
      isLoading.value = false;
    }, onError: (_) => isLoading.value = false);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}