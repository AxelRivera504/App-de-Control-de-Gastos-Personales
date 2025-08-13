import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:app_control_gastos_personales/application/controllers/analysis/analysis_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AnalysisScreen extends StatelessWidget {
  static const name = 'analysis-screen';

  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalysisController());
    
    return BaseDesign(
      header: _HeaderAnalysis(controller),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          children: [
            _buildPeriodSelector(controller),
            const SizedBox(height: 24),
            _buildChartHeader(),
            const SizedBox(height: 16),
            Expanded(child: _buildBarChart(controller)),
            const SizedBox(height: 24),
            _buildIncomeExpenseRow(controller),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(AnalysisController controller) {
    const periods = ['Diario', 'Semanal', 'Mensual', 'Anual'];
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Obx(() => Row(
        children: periods.asMap().entries.map((entry) {
          final isSelected = controller.selectedPeriod.value == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changePeriod(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.verde : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(entry.value, textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  )),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Ingresos y Gastos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // TODO: Navegar a pantalla de búsqueda
                print('Búsqueda presionada');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.verde,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // TODO: Navegar a pantalla de calendario
                print('Calendario presionado');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.verde,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart(AnalysisController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.verde));
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _buildBars(controller),
              ),
            ),
            const SizedBox(height: 16),
            _buildChartLabels(controller),
          ],
        ),
      );
    });
  }

  List<Widget> _buildBars(AnalysisController controller) {
    final data = controller.chartData;
    if (data.isEmpty) return [const Text('No hay datos disponibles')];

    final maxAmount = data.map((e) => [e.income, e.expenses].reduce((a, b) => a > b ? a : b)).reduce((a, b) => a > b ? a : b);
    if (maxAmount == 0) return [const Text('No hay datos disponibles')];

    return data.map((item) {
      final incomeHeight = (item.income / maxAmount * 180).clamp(4.0, 180.0);
      final expenseHeight = (item.expenses / maxAmount * 180).clamp(4.0, 180.0);

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Barra de ingresos (verde claro)
              Container(
                width: 16,
                height: incomeHeight,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: AppTheme.verde.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Barra de gastos (azul oscuro)
              Container(
                width: 16,
                height: expenseHeight,
                decoration: BoxDecoration(
                  color: AppTheme.azulOscuro,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildChartLabels(AnalysisController controller) {
    final data = controller.chartData;
    if (data.isEmpty) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.map((item) => Expanded(
        child: Text(
          item.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildIncomeExpenseRow(AnalysisController controller) {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _buildIncomeExpenseCard(
            'Ingresos',
            controller.totalIncome.value,
            AppTheme.verde,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildIncomeExpenseCard(
            'Gastos',
            controller.totalExpenses.value,
            AppTheme.azulOscuro,
            Icons.trending_down,
          ),
        ),
      ],
    ));
  }

  Widget _buildIncomeExpenseCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "\$${NumberFormat('#,##0.00').format(amount)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAnalysis extends StatelessWidget {
  final AnalysisController controller;
  
  const _HeaderAnalysis(this.controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const NavigationHeader(
            title: 'Análisis',
            showNotifications: true,
          ),
          const SizedBox(height: 20),
          _buildBalanceRow(),
          _buildProgressSection(),
        ],
      ),
    );
  }

  Widget _buildBalanceRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Row(
        children: [
          _buildBalanceCard('Balance Total', controller.totalBalance.value, Icons.account_balance_wallet_outlined),
          Container(width: 1, height: 50, color: Colors.white30),
          _buildBalanceCard('Gastos Totales', -controller.totalExpenses.value, Icons.trending_down, isExpense: true),
        ],
      )),
    );
  }

  Widget _buildBalanceCard(String title, double amount, IconData icon, {bool isExpense = false}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: isExpense ? 16 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "\$${NumberFormat('#,##0.00').format(amount.abs())}",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        final percentage = controller.getExpensePercentage();
        return Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${percentage.round()}%', style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text("\$${NumberFormat('#,##0.00').format(controller.totalIncome.value)}", 
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 12,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text('${percentage.round()}% de tus gastos. ¡Se ve bien!',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }
}