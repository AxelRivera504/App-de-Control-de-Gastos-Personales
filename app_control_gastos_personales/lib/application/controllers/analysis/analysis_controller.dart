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

  /// 👇 HAZLA REACTIVA
  final RxList<ChartDataItem> chartData = <ChartDataItem>[].obs;


  @override
  void onInit() {
    super.onInit();
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
      // ignore: avoid_print
      print('Error cargando datos de análisis: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadDailyData(String uid, DateTime start, DateTime end) async {
    final transactions = await _getTransactionsInRange(uid, start, end);

    // Prepara 7 días (lun..dom) relativo a hoy
    final Map<String, Map<String, double>> dailyTotals = {};
    for (int i = 0; i < 7; i++) {
      final date = end.subtract(Duration(days: 6 - i));
      final dayKey = _formatDay(date);
      dailyTotals[dayKey] = {'income': 0.0, 'expenses': 0.0};
    }

    for (final t in transactions) {
      final dayKey = _formatDay(t.date);
      if (!dailyTotals.containsKey(dayKey)) continue;
      if (t.trantypeid == 1) {
        dailyTotals[dayKey]!['income'] = dailyTotals[dayKey]!['income']! + t.amount;
      } else {
        dailyTotals[dayKey]!['expenses'] = dailyTotals[dayKey]!['expenses']! + t.amount;
      }
    }

    // Orden garantizado según creación
    final orderedKeys = dailyTotals.keys.toList();
    final dailyData = orderedKeys
        .map((k) => ChartDataItem(
              label: k,
              income: dailyTotals[k]!['income']!,
              expenses: dailyTotals[k]!['expenses']!,
            ))
        .toList();

    chartData.assignAll(dailyData);
    _calculateTotals(dailyData);
  }

  Future<void> _loadWeeklyData(String uid, DateTime start, DateTime end) async {
    final transactions = await _getTransactionsInRange(uid, start, end);

    // 4 semanas
    final Map<String, Map<String, double>> weeklyTotals = {
      '1ª Sem': {'income': 0.0, 'expenses': 0.0},
      '2ª Sem': {'income': 0.0, 'expenses': 0.0},
      '3ª Sem': {'income': 0.0, 'expenses': 0.0},
      '4ª Sem': {'income': 0.0, 'expenses': 0.0},
    };

    for (final t in transactions) {
      final daysDiff = end.difference(t.date).inDays;
      final weekIndex = (daysDiff / 7).floor(); // 0..3
      if (weekIndex < 0 || weekIndex > 3) continue;
      final weekKey = '${4 - weekIndex}ª Sem'; // más reciente es 4ª Sem
      if (t.trantypeid == 1) {
        weeklyTotals[weekKey]!['income'] = weeklyTotals[weekKey]!['income']! + t.amount;
      } else {
        weeklyTotals[weekKey]!['expenses'] = weeklyTotals[weekKey]!['expenses']! + t.amount;
      }
    }

    final orderedKeys = ['1ª Sem', '2ª Sem', '3ª Sem', '4ª Sem'];
    final weeklyData = orderedKeys
        .map((k) => ChartDataItem(
              label: k,
              income: weeklyTotals[k]!['income']!,
              expenses: weeklyTotals[k]!['expenses']!,
            ))
        .toList();

    chartData.assignAll(weeklyData);
    _calculateTotals(weeklyData);
  }

  Future<void> _loadMonthlyData(String uid, DateTime start, DateTime end) async {
    final transactions = await _getTransactionsInRange(uid, start, end);

    final Map<String, Map<String, double>> monthlyTotals = {};
    for (int i = 0; i < 6; i++) {
      final month = DateTime(end.year, end.month - (5 - i), 1);
      final monthKey = _formatMonth(month);
      monthlyTotals[monthKey] = {'income': 0.0, 'expenses': 0.0};
    }

    for (final t in transactions) {
      final monthKey = _formatMonth(t.date);
      if (!monthlyTotals.containsKey(monthKey)) continue;
      if (t.trantypeid == 1) {
        monthlyTotals[monthKey]!['income'] = monthlyTotals[monthKey]!['income']! + t.amount;
      } else {
        monthlyTotals[monthKey]!['expenses'] = monthlyTotals[monthKey]!['expenses']! + t.amount;
      }
    }

    final orderedKeys = monthlyTotals.keys.toList();
    final monthlyData = orderedKeys
        .map((k) => ChartDataItem(
              label: k,
              income: monthlyTotals[k]!['income']!,
              expenses: monthlyTotals[k]!['expenses']!,
            ))
        .toList();

    chartData.assignAll(monthlyData);
    _calculateTotals(monthlyData);
  }

  Future<void> _loadYearlyData(String uid, DateTime start, DateTime end) async {
    final transactions = await _getTransactionsInRange(uid, start, end);

    final Map<String, Map<String, double>> yearlyTotals = {};
    for (int i = 0; i < 5; i++) {
      final year = end.year - (4 - i);
      yearlyTotals[year.toString()] = {'income': 0.0, 'expenses': 0.0};
    }

    for (final t in transactions) {
      final key = t.date.year.toString();
      if (!yearlyTotals.containsKey(key)) continue;
      if (t.trantypeid == 1) {
        yearlyTotals[key]!['income'] = yearlyTotals[key]!['income']! + t.amount;
      } else {
        yearlyTotals[key]!['expenses'] = yearlyTotals[key]!['expenses']! + t.amount;
      }
    }

    final orderedKeys = yearlyTotals.keys.toList();
    final yearlyData = orderedKeys
        .map((k) => ChartDataItem(
              label: k,
              income: yearlyTotals[k]!['income']!,
              expenses: yearlyTotals[k]!['expenses']!,
            ))
        .toList();

    chartData.assignAll(yearlyData);
    _calculateTotals(yearlyData);
  }

  Future<List<TransactionData>> _getTransactionsInRange(
      String uid, DateTime start, DateTime end) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userid', isEqualTo: uid) // <- tu campo en BD
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
      // ignore: avoid_print
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
