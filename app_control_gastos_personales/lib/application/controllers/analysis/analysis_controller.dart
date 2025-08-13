import 'package:app_control_gastos_personales/infrastucture/datasources/category_datasource.dart';
import 'package:app_control_gastos_personales/infrastucture/datasources/transaction_datasource.dart';
import 'package:get/get.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChartDataItem {
  final String label;
  final double income;
  final double expenses;

  ChartDataItem({
    required this.label,
    required this.income,
    required this.expenses,
  });
}

class AnalysisController extends GetxController {
  final RxInt selectedPeriod = 0.obs; // 0=Diario, 1=Semanal, 2=Mensual, 3=Anual
  final RxBool isLoading = false.obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble totalBalance = 0.0.obs;
  final RxList<ChartDataItem> chartData = <ChartDataItem>[].obs;

  late final TransactionDatasourceImpl _transactionDatasource;
  late final CategoryDatasourceImpl _categoryDatasource;

  @override
  void onInit() {
    super.onInit();
    _transactionDatasource = TransactionDatasourceImpl(FirebaseFirestore.instance);
    _categoryDatasource = CategoryDatasourceImpl(FirebaseFirestore.instance);
    _loadData();
  }

  void changePeriod(int period) {
    selectedPeriod.value = period;
    _loadData();
  }

  double getExpensePercentage() {
    if (totalIncome.value == 0) return 0.0;
    return (totalExpenses.value / totalIncome.value * 100).clamp(0.0, 100.0);
  }

  Future<void> _loadData() async {
    final userId = SessionController.instance.userId;
    if (userId == null) return;

    isLoading.value = true;
    
    try {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;

      switch (selectedPeriod.value) {
        case 0: // Diario - últimos 7 días
          startDate = now.subtract(const Duration(days: 7));
          await _loadDailyData(userId, startDate, endDate);
          break;
        case 1: // Semanal - últimas 4 semanas
          startDate = now.subtract(const Duration(days: 28));
          await _loadWeeklyData(userId, startDate, endDate);
          break;
        case 2: // Mensual - últimos 6 meses
          startDate = DateTime(now.year, now.month - 6, 1);
          await _loadMonthlyData(userId, startDate, endDate);
          break;
        case 3: // Anual - últimos 5 años
          startDate = DateTime(now.year - 5, 1, 1);
          await _loadYearlyData(userId, startDate, endDate);
          break;
      }
    } catch (e) {
      print('Error cargando datos de análisis: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadDailyData(String uid, DateTime start, DateTime end) async {
    final transactions = await _getTransactionsInRange(uid, start, end);
    final List<ChartDataItem> dailyData = [];
    
    final Map<String, Map<String, double>> dailyTotals = {};
    
    for (int i = 0; i < 7; i++) {
      final date = end.subtract(Duration(days: 6 - i));
      final dayKey = _formatDay(date);
      dailyTotals[dayKey] = {'income': 0.0, 'expenses': 0.0};
    }

    for (final transaction in transactions) {
      final dayKey = _formatDay(transaction.date);
      if (dailyTotals.containsKey(dayKey)) {
        if (transaction.trantypeid == 1) {
          dailyTotals[dayKey]!['income'] = dailyTotals[dayKey]!['income']! + transaction.amount;
        } else {
          dailyTotals[dayKey]!['expenses'] = dailyTotals[dayKey]!['expenses']! + transaction.amount;
        }
      }
    }

    dailyTotals.forEach((key, value) {
      dailyData.add(ChartDataItem(
        label: key,
        income: value['income']!,
        expenses: value['expenses']!,
      ));
    });

    chartData.value = dailyData;
    _calculateTotals(dailyData);
  }

  Future<void> _loadWeeklyData(String uid, DateTime start, DateTime end) async {
    final transactions = await _getTransactionsInRange(uid, start, end);
    final List<ChartDataItem> weeklyData = [];
    
    final Map<String, Map<String, double>> weeklyTotals = {};
    
    for (int i = 0; i < 4; i++) {
      final weekKey = '${i + 1}ª Sem';
      weeklyTotals[weekKey] = {'income': 0.0, 'expenses': 0.0};
    }

    for (final transaction in transactions) {
      final daysDiff = end.difference(transaction.date).inDays;
      final weekIndex = (daysDiff / 7).floor();
      if (weekIndex < 4) {
        final weekKey = '${4 - weekIndex}ª Sem';
        if (weeklyTotals.containsKey(weekKey)) {
          if (transaction.trantypeid == 1) {
            weeklyTotals[weekKey]!['income'] = weeklyTotals[weekKey]!['income']! + transaction.amount;
          } else {
            weeklyTotals[weekKey]!['expenses'] = weeklyTotals[weekKey]!['expenses']! + transaction.amount;
          }
        }
      }
    }

    weeklyTotals.forEach((key, value) {
      weeklyData.add(ChartDataItem(
        label: key,
        income: value['income']!,
        expenses: value['expenses']!,
      ));
    });

    chartData.value = weeklyData;
    _calculateTotals(weeklyData);
  }

  Future<void> _loadMonthlyData(String uid, DateTime start, DateTime end) async {
    final transactions = await _getTransactionsInRange(uid, start, end);
    final List<ChartDataItem> monthlyData = [];
    
    final Map<String, Map<String, double>> monthlyTotals = {};
    
    for (int i = 0; i < 6; i++) {
      final month = DateTime(end.year, end.month - (5 - i), 1);
      final monthKey = _formatMonth(month);
      monthlyTotals[monthKey] = {'income': 0.0, 'expenses': 0.0};
    }

    for (final transaction in transactions) {
      final monthKey = _formatMonth(transaction.date);
      if (monthlyTotals.containsKey(monthKey)) {
        if (transaction.trantypeid == 1) {
          monthlyTotals[monthKey]!['income'] = monthlyTotals[monthKey]!['income']! + transaction.amount;
        } else {
          monthlyTotals[monthKey]!['expenses'] = monthlyTotals[monthKey]!['expenses']! + transaction.amount;
        }
      }
    }

    monthlyTotals.forEach((key, value) {
      monthlyData.add(ChartDataItem(
        label: key,
        income: value['income']!,
        expenses: value['expenses']!,
      ));
    });

    chartData.value = monthlyData;
    _calculateTotals(monthlyData);
  }

  Future<void> _loadYearlyData(String uid, DateTime start, DateTime end) async {
    final transactions = await _getTransactionsInRange(uid, start, end);
    final List<ChartDataItem> yearlyData = [];
    
    final Map<String, Map<String, double>> yearlyTotals = {};
    
    for (int i = 0; i < 5; i++) {
      final year = end.year - (4 - i);
      final yearKey = year.toString();
      yearlyTotals[yearKey] = {'income': 0.0, 'expenses': 0.0};
    }

    for (final transaction in transactions) {
      final yearKey = transaction.date.year.toString();
      if (yearlyTotals.containsKey(yearKey)) {
        if (transaction.trantypeid == 1) {
          yearlyTotals[yearKey]!['income'] = yearlyTotals[yearKey]!['income']! + transaction.amount;
        } else {
          yearlyTotals[yearKey]!['expenses'] = yearlyTotals[yearKey]!['expenses']! + transaction.amount;
        }
      }
    }

    yearlyTotals.forEach((key, value) {
      yearlyData.add(ChartDataItem(
        label: key,
        income: value['income']!,
        expenses: value['expenses']!,
      ));
    });

    chartData.value = yearlyData;
    _calculateTotals(yearlyData);
  }

  Future<List<TransactionData>> _getTransactionsInRange(String uid, DateTime start, DateTime end) async {
    try {
      // CORREGIDO: Cambié 'usercreate' por 'userid' según tu estructura de BD
      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userid', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionData(
          id: doc.id,
          amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
          date: (data['date'] as Timestamp).toDate(),
          trantypeid: (data['trantypeid'] as int?) ?? 1,
        );
      }).toList();
    } catch (e) {
      print('Error obteniendo transacciones: $e');
      return [];
    }
  }

  void _calculateTotals(List<ChartDataItem> data) {
    double income = 0.0;
    double expenses = 0.0;

    for (final item in data) {
      income += item.income;
      expenses += item.expenses;
    }

    totalIncome.value = income;
    totalExpenses.value = expenses;
    totalBalance.value = income - expenses;
  }

  String _formatDay(DateTime date) {
    const days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    return days[date.weekday - 1];
  }

  String _formatMonth(DateTime date) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }
}

class TransactionData {
  final String id;
  final double amount;
  final DateTime date;
  final int trantypeid;

  TransactionData({
    required this.id,
    required this.amount,
    required this.date,
    required this.trantypeid,
  });
}