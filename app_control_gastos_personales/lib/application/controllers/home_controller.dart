import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_control_gastos_personales/domain/entities/transaction.dart';
import 'package:app_control_gastos_personales/domain/entities/category.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';

// Clase para combinar transacción con categoría
class TransactionWithCategory {
  final TransactionEntity transaction;
  final Category? category;

  TransactionWithCategory({
    required this.transaction,
    this.category,
  });
}

class HomeController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Observables para el balance y gastos
  final totalBalance = 0.0.obs;
  final totalIncome = 0.0.obs;
  final totalExpenses = 0.0.obs;
  
  // Observables para estadísticas semanales
  final revenueLastWeek = 0.0.obs;
  final expensesLastWeek = 0.0.obs;
  
  // Lista de transacciones con categorías
  final RxList<TransactionWithCategory> transactions = <TransactionWithCategory>[].obs;
  final isLoading = false.obs;
  
  // Selector de período (0=Diario, 1=Semanal, 2=Mensual)
  final selectedPeriod = 2.obs; // Por defecto Mensual
  
  // Cache de categorías para mejorar rendimiento
  final Map<String, Category> _categoriesCache = {};

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  // Método principal para cargar todos los datos
  Future<void> _loadData() async {
    await SessionController.instance.loadSession();
    final userId = SessionController.instance.userId;
    
    if (userId == null || userId.isEmpty) {
      return;
    }

    isLoading.value = true;
    
    try {
      // Cargar categorías primero (para el cache)
      await _loadCategories();
      
      // Cargar transacciones del período actual
      await _loadTransactions(userId);
      
      // Calcular estadísticas
      _calculateStats();
      _calculateWeeklyStats(userId);
      
    } catch (e) {
      print('Error cargando datos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Cargar categorías y guardarlas en cache
  Future<void> _loadCategories() async {
    try {
      final snapshot = await _db.collection('categories').get();
      _categoriesCache.clear();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = Category(
          id: doc.id,
          description: data['description'] ?? '',
          state: data['state'] ?? true,
          userCreate: data['userCreate'] ?? '',
          createDate: data['createDate'] != null 
              ? (data['createDate'] as Timestamp).toDate() 
              : null,
          iconCodePoint: data['iconCodePoint'] ?? Icons.category.codePoint,
          iconFontFamily: data['iconFontFamily'] ?? Icons.category.fontFamily ?? '',
          iconFontPackage: data['iconFontPackage'],
          defaultTypeId: data['defaultTypeId'] ?? 2,
        );
        _categoriesCache[doc.id] = category;
      }
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }

  // Cargar transacciones según el período seleccionado
  Future<void> _loadTransactions(String userId) async {
    final dateRange = _getDateRangeForPeriod();
    
    try {
      final query = await _db
          .collection('transactions')
          .where('userid', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end))
          .orderBy('date', descending: true)
          .get();

      final List<TransactionWithCategory> transactionsList = [];

      for (var doc in query.docs) {
        final data = doc.data();
        final transaction = TransactionEntity(
          id: doc.id,
          userId: data['userid'] ?? '',
          categoryId: data['categoryid'] ?? '',
          trantypeid: data['trantypeid'] ?? 2,
          amount: (data['amount'] ?? 0.0).toDouble(),
          date: (data['date'] as Timestamp).toDate(),
          notes: data['notes'],
        );

        final category = _categoriesCache[transaction.categoryId];
        
        transactionsList.add(TransactionWithCategory(
          transaction: transaction,
          category: category,
        ));
      }

      transactions.value = transactionsList;
    } catch (e) {
      print('Error cargando transacciones: $e');
      transactions.value = [];
    }
  }

  // Obtener rango de fechas según el período seleccionado
  DateRange _getDateRangeForPeriod() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedPeriod.value) {
      case 0: // Diario
        return DateRange(
          start: today,
          end: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1))
        );
      
      case 1: // Semanal
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
        return DateRange(start: startOfWeek, end: endOfWeek);
      
      case 2: // Mensual
      default:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
        return DateRange(start: startOfMonth, end: endOfMonth);
    }
  }

  // Calcular estadísticas principales
  void _calculateStats() {
    double income = 0.0;
    double expenses = 0.0;

    for (var item in transactions) {
      if (item.transaction.trantypeid == 1) {
        income += item.transaction.amount;
      } else {
        expenses += item.transaction.amount;
      }
    }

    totalIncome.value = income;
    totalExpenses.value = expenses;
    totalBalance.value = income - expenses;
  }

  // Calcular estadísticas de la semana pasada
  void _calculateWeeklyStats(String userId) async {
    final now = DateTime.now();
    final startOfLastWeek = now.subtract(Duration(days: now.weekday + 6));
    final endOfLastWeek = now.subtract(Duration(days: now.weekday));

    try {
      final query = await _db
          .collection('transactions')
          .where('userid', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfLastWeek))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfLastWeek))
          .get();

      double weeklyIncome = 0.0;
      double weeklyExpenses = 0.0;

      for (var doc in query.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0.0).toDouble();
        final type = data['trantypeid'] ?? 2;

        if (type == 1) {
          weeklyIncome += amount;
        } else {
          weeklyExpenses += amount;
        }
      }

      revenueLastWeek.value = weeklyIncome;
      expensesLastWeek.value = weeklyExpenses;
    } catch (e) {
      print('Error calculando estadísticas semanales: $e');
    }
  }

  // Obtener porcentaje de gastos
  double getExpensePercentage() {
    if (totalIncome.value == 0) return 0.0;
    return (totalExpenses.value / totalIncome.value) * 100;
  }

  // Obtener mensaje motivacional
  String getMotivationalMessage() {
    final percentage = getExpensePercentage();
    
    if (percentage <= 30) {
      return '¡Excelente control!';
    } else if (percentage <= 50) {
      return '¡Buen trabajo!';
    } else if (percentage <= 70) {
      return 'Puedes mejorar';
    } else if (percentage <= 90) {
      return 'Cuidado con los gastos';
    } else {
      return '¡Revisa tu presupuesto!';
    }
  }

  // Cambiar período de visualización
  void changePeriod(int newPeriod) async {
    if (selectedPeriod.value == newPeriod) return;
    
    selectedPeriod.value = newPeriod;
    await _loadData(); // Recargar datos para el nuevo período
  }

  // Método para refrescar datos (pull to refresh)
  @override
  Future<void> refresh() async {
    await _loadData();
  }
}

// Clase auxiliar para rangos de fechas
class DateRange {
  final DateTime start;
  final DateTime end;
  
  DateRange({required this.start, required this.end});
}