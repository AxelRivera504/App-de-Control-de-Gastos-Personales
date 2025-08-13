import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/screens/auth/login_screen.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';
import 'package:app_control_gastos_personales/application/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home-screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    
    return Scaffold(
      backgroundColor: AppTheme.verde,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildBalanceRow(controller),
            _buildProgressSection(controller),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    children: [
                      _buildWeeklyStats(controller),
                      const SizedBox(height: 24),
                      _buildPeriodSelector(controller),
                      const SizedBox(height: 16),
                      Expanded(child: _buildTransactionsList(controller)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Buenos días' : hour < 18 ? 'Buenas tardes' : 'Buenas noches';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hola, Bienvenido', 
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          // Botón de notificaciones removido
          GestureDetector(
            onTap: () {
              SessionController.instance.clearSession();
              context.goNamed(LoginScreen.name);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.logout, color: AppTheme.verdeOscuro, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(HomeController controller) {
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

  Widget _buildProgressSection(HomeController controller) {
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
                Text('${percentage.round()}% de tus gastos. ${controller.getMotivationalMessage()}',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildWeeklyStats(HomeController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.verde.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildStatRow('Ingresos semana pasada', controller.revenueLastWeek.value, 
            Icons.directions_car_outlined, AppTheme.verde),
          Container(margin: const EdgeInsets.symmetric(vertical: 16), height: 1, color: Colors.grey.shade300),
          _buildStatRow('Gastos semana pasada', controller.expensesLastWeek.value, 
            Icons.restaurant_outlined, AppTheme.anarajando),
        ],
      ),
    ));
  }

  Widget _buildStatRow(String title, double amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text("\$${NumberFormat('#,##0.00').format(amount)}", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(HomeController controller) {
    const periods = ['Diario', 'Semanal', 'Mensual'];
    
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

  Widget _buildTransactionsList(HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.verde));
      }
      
      if (controller.transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No hay transacciones', 
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('Agrega tu primera transacción para comenzar', 
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500), textAlign: TextAlign.center),
            ],
          ),
        );
      }
      
      return ListView.separated(
        itemCount: controller.transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = controller.transactions[index];
          final transaction = item.transaction;
          final category = item.category;
          final isIncome = transaction.trantypeid == 1;
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.azulOscuro,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category?.iconData ?? Icons.category, 
                    color: AppTheme.blancoPalido, 
                    size: 24
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category?.description ?? 'Categoría desconocida', 
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Text(DateFormat('HH:mm - MMMM dd', 'es').format(transaction.date),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(isIncome ? 'Mensual' : category?.description ?? 'Gasto',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text("${isIncome ? '' : '-'}\$${NumberFormat('#,##0.00').format(transaction.amount)}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, 
                        color: isIncome ? Colors.green : Colors.red)),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }
}






