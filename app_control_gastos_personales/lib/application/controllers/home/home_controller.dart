import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_control_gastos_personales/domain/entities/transaction.dart';
import 'package:app_control_gastos_personales/domain/entities/category.dart';
import 'package:app_control_gastos_personales/infrastucture/datasources/transaction_datasource.dart';
import 'package:app_control_gastos_personales/infrastucture/repositories/transaction_repository_impl.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';

class HomeController extends GetxController {
  final isLoading = true.obs;
  final transactions = <TransactionWithCategory>[].obs;
  final selectedPeriod = 0.obs; // 0: Diario, 1: Semanal, 2: Mensual
  
  // Estadisticas
  final totalBalance = 0.0.obs;
  final totalExpenses = 0.0.obs;
  final totalIncome = 0.0.obs;
  final revenueLastWeek = 0.0.obs;
  final expensesLastWeek = 0.0.obs;
  
  StreamSubscription<QuerySnapshot>? _transactionsSub;
  StreamSubscription<QuerySnapshot>? _categoriesSub;
  String? _uid;
  
  final _categories = <String, Category>{};
  final _allTransactions = <TransactionEntity>[];
  
  final _datasource = TransactionDatasourceImpl(FirebaseFirestore.instance);
  late final _repo = TransactionRepositoryImpl(_datasource);

  @override
  void onInit() {
    super.onInit();
    _uid = SessionController.instance.userId;
    _initializeData();
  }

  void _initializeData() {
    _subscribeToCategories();
    _subscribeToTransactions();
  }

  void _subscribeToCategories() {
    _categoriesSub?.cancel();
    final uid = _uid;
    if (uid == null || uid.isEmpty) return;

    _categoriesSub = FirebaseFirestore.instance
        .collection('categories')
        .where('usercreate', isEqualTo: uid)
        .where('state', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _categories.clear();
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final category = Category(
            id: doc.id,
            description: data['description']?.toString() ?? '',
            state: data['state'] == true,
            userCreate: data['usercreate']?.toString() ?? '',
            createDate: data['createdate'] != null 
                ? (data['createdate'] as Timestamp).toDate()
                : null,
            iconCodePoint: (data['iconCodePoint'] as num?)?.toInt() ?? 0xe0b7,
            iconFontFamily: data['iconFontFamily']?.toString() ?? 'MaterialIcons',
            iconFontPackage: data['iconFontPackage']?.toString(),
            defaultTypeId: (data['defaultTypeId'] as num?)?.toInt() ?? 1,
          );
          _categories[doc.id] = category;
        } catch (e) {
          print('Error parsing category ${doc.id}: $e');
        }
      }
      _updateTransactionsWithCategories();
    });
  }

  void _subscribeToTransactions() {
    _transactionsSub?.cancel();
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _transactionsSub = FirebaseFirestore.instance
        .collection('transactions')
        .where('userid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _allTransactions.clear();
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final transaction = TransactionEntity(
            id: doc.id,
            userId: data['userid']?.toString() ?? '',
            categoryId: data['categoryid']?.toString() ?? '',
            trantypeid: (data['trantypeid'] as num?)?.toInt() ?? 1,
            amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
            date: data['date'] != null 
                ? (data['date'] as Timestamp).toDate()
                : DateTime.now(),
            notes: data['notes']?.toString(),
          );
          _allTransactions.add(transaction);
        } catch (e) {
          print('Error parsing transaction ${doc.id}: $e');
        }
      }
      
      _calculateStats();
      _updateTransactionsWithCategories();
      isLoading.value = false;
    }, onError: (error) {
      print('Error in transactions stream: $error');
      isLoading.value = false;
    });
  }

  void _calculateStats() {
    double income = 0.0;
    double expenses = 0.0;
    double lastWeekIncome = 0.0;
    double lastWeekExpenses = 0.0;
    
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    
    for (final tx in _allTransactions) {
      final isIncome = tx.trantypeid == 1;
      final amount = tx.amount;
      
      if (isIncome) {
        income += amount;
        // Ingresos de la semana pasada 
        if (tx.date.isAfter(twoWeeksAgo) && tx.date.isBefore(oneWeekAgo)) {
          lastWeekIncome += amount;
        }
      } else {
        expenses += amount;
        // Gastos de la semana pasada
        if (tx.date.isAfter(twoWeeksAgo) && tx.date.isBefore(oneWeekAgo)) {
          lastWeekExpenses += amount;
        }
      }
    }
    
    totalIncome.value = income;
    totalExpenses.value = expenses;
    totalBalance.value = income - expenses;
    revenueLastWeek.value = lastWeekIncome;
    expensesLastWeek.value = lastWeekExpenses;
  }

  void _updateTransactionsWithCategories() {
    final filtered = _filterTransactionsByPeriod();
    final withCategories = filtered.map((tx) {
      final category = _categories[tx.categoryId];
      return TransactionWithCategory(transaction: tx, category: category);
    }).toList();
    
    transactions.assignAll(withCategories);
  }

  List<TransactionEntity> _filterTransactionsByPeriod() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _allTransactions.where((tx) {
      switch (selectedPeriod.value) {
        case 0: // Diario
          final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
          return txDate.isAtSameMomentAs(today);
          
        case 1: // Semanal
          final weekAgo = today.subtract(const Duration(days: 7));
          return tx.date.isAfter(weekAgo) && tx.date.isBefore(today.add(const Duration(days: 1)));
          
        case 2: // Mensual
          final monthAgo = DateTime(now.year, now.month - 1, now.day);
          return tx.date.isAfter(monthAgo);
          
        default:
          return true;
      }
    }).toList();
  }

  void changePeriod(int period) {
    selectedPeriod.value = period;
    _updateTransactionsWithCategories();
  }

  String getMotivationalMessage() {
    if (totalIncome.value == 0) return 'Comienza agregando tus ingresos';
    
    final percentage = (totalExpenses.value / totalIncome.value * 100);
    
    if (percentage < 20) {
      return '¡Excelente ahorro! Sigue así';
    } else if (percentage < 50) {
      return '¡Buen control de gastos!';
    } else if (percentage < 80) {
      return 'Mantén el control de tus gastos';
    } else {
      return 'Revisa tus gastos este mes';
    }
  }

  double getExpensePercentage() {
    if (totalIncome.value == 0) return 0.0;
    return (totalExpenses.value / totalIncome.value * 100).clamp(0.0, 100.0);
  }

  ///cambio de usuario
  void setUser(String? uid) {
    _uid = uid;
    _categories.clear();
    _allTransactions.clear();
    transactions.clear();
    totalBalance.value = 0.0;
    totalExpenses.value = 0.0;
    totalIncome.value = 0.0;
    revenueLastWeek.value = 0.0;
    expensesLastWeek.value = 0.0;
    
    if (uid != null && uid.isNotEmpty) {
      _initializeData();
    } else {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _transactionsSub?.cancel();
    _categoriesSub?.cancel();
    super.onClose();
  }
}

//combinar transaccion con categoria
class TransactionWithCategory {
  final TransactionEntity transaction;
  final Category? category;

  TransactionWithCategory({
    required this.transaction,
    this.category,
  });
}