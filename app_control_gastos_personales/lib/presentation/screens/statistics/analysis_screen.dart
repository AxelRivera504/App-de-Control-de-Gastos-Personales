import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:app_control_gastos_personales/application/controllers/analysis/analysis_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AnalysisScreen extends StatelessWidget {
  static const name = 'analysis-screen';
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<AnalysisController>()
        ? Get.find<AnalysisController>()
        : Get.put(AnalysisController());

    return BaseDesign(
      header: _HeaderAnalysis(c),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _periodSelector(c),
            const SizedBox(height: 24),
            _chartHeader(context),
            const SizedBox(height: 12),
            _barChart(c),                // altura fija, sin overflow
            const SizedBox(height: 16),
            _incomeExpenseRow(c),
          ],
        ),
      ),
    );
  }

  Widget _periodSelector(AnalysisController c) {
    const periods = ['Diario', 'Semanal', 'Mensual', 'Anual'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() {
        final selected = c.selectedPeriod.value;
        return Row(
          children: periods.asMap().entries.map((e) {
            final i = e.key;
            final isSel = selected == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => c.changePeriod(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.verde : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    e.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSel ? Colors.white : Colors.grey.shade600,
                      fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _chartHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Ingresos y Gastos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        // BOTONES COMENTADOS - Descomenta cuando implementes las pantallas
        /*
        Row(
          children: [
            _headerIcon(icon: Icons.search, onTap: () => context.push('/analysis/search')),
            const SizedBox(width: 8),
            _headerIcon(icon: Icons.calendar_today, onTap: () => context.push('/analysis/calendar')),
          ],
        ),
        */
      ],
    );
  }

  // FUNCIÓN COMENTADA - Descomenta cuando implementes las pantallas
  /*
  Widget _headerIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.verde, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
  */

Widget _barChart(AnalysisController c) {
  return Obx(() {
    // Alturas fijas y márgenes de seguridad
    const double chartHeight = 260;
    const double barsArea = 170;
    const double labelsArea = 24;
    const double bottomSafe = 8;   // evita tocar la zona de etiquetas
    const double barWidth = 10;    // ancho de cada barra
    const double pairGap = 6;      // separación entre ingreso y egreso

    if (c.isLoading.value) {
      return const SizedBox(
        height: chartHeight,
        child: Center(child: CircularProgressIndicator(color: AppTheme.verde)),
      );
    }

    final data = c.chartData;
    if (data.isEmpty) {
      return const SizedBox(
        height: chartHeight,
        child: Center(child: Text('No hay datos disponibles')),
      );
    }

    final maxAmount = data
        .map((e) => e.income > e.expenses ? e.income : e.expenses)
        .fold<double>(0, (a, b) => a > b ? a : b);

    double h(double v) {
      if (maxAmount == 0) return 4;
      final hh = (v / maxAmount) * (barsArea - bottomSafe);
      return hh.clamp(4, barsArea - bottomSafe);
    }

    return Container(
      height: chartHeight,
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Área de barras (dos por período, lado a lado)
          SizedBox(
            height: barsArea,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                return Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: barsArea,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Ingreso (verde)
                          Container(
                            width: barWidth,
                            height: h(item.income),
                            decoration: BoxDecoration(
                              color: AppTheme.verde.withOpacity(.85),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          SizedBox(width: pairGap),
                          // Egreso (azul)
                          Container(
                            width: barWidth,
                            height: h(item.expenses),
                            decoration: BoxDecoration(
                              color: AppTheme.azulOscuro,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Etiquetas
          SizedBox(
            height: labelsArea,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: data
                  .map((e) => Expanded(
                        child: Text(
                          e.label,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  });
}


  Widget _incomeExpenseRow(AnalysisController c) {
    return Obx(() => Row(
          children: [
            Expanded(child: _amountCard('Ingresos', c.totalIncome.value, AppTheme.verde, Icons.trending_up)),
            const SizedBox(width: 16),
            Expanded(child: _amountCard('Gastos', c.totalExpenses.value, AppTheme.azulOscuro, Icons.trending_down)),
          ],
        ));
  }

  Widget _amountCard(String title, double amount, Color color, IconData icon) {
  return SizedBox(
    height: 120, // alto fijo para todas las tarjetas
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // centra verticalmente
        crossAxisAlignment: CrossAxisAlignment.center, // centra horizontalmente
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
          FittedBox( // evita que el texto se corte si es muy largo
            child: Text(
              "\$${NumberFormat('#,##0.00').format(amount)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}

class _HeaderAnalysis extends StatelessWidget {
  final AnalysisController c;
  const _HeaderAnalysis(this.c);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const NavigationHeader(title: 'Análisis', showNotifications: false, showBackButton: false),
        const SizedBox(height: 20),
        _balanceRow(),
        _progress(),
      ],
    );
  }

  Widget _balanceRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GetX<AnalysisController>(builder: (ctrl) {
        return Row(
          children: [
            _balanceCard('Balance Total', ctrl.totalBalance.value, Icons.account_balance_wallet_outlined),
            Container(width: 1, height: 50, color: Colors.white30),
            _balanceCard('Gastos Totales', -ctrl.totalExpenses.value, Icons.trending_down, isExpense: true),
          ],
        );
      }),
    );
  }

  Widget _balanceCard(String title, double amount, IconData icon, {bool isExpense = false}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: isExpense ? 16 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
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

  Widget _progress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        final p = c.getExpensePercentage();
        return Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${p.round()}%', style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(
                  "\$${NumberFormat('#,##0.00').format(c.totalIncome.value)}",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (p / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 12,
            ),
            const SizedBox(height: 12),
            Row(children: const [
              Icon(Icons.trending_up, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('100% de tus gastos. ¡Se ve bien!', style: TextStyle(color: Colors.white, fontSize: 13)),
            ]),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }
}
