import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:app_control_gastos_personales/utils/icon_helper.dart';
import 'package:flutter/material.dart';

class TransactionsScreen extends StatefulWidget {
  static const name = 'transactions-screen';

  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? selectedFilter; // null = todas, 'income' = ingresos, 'expense' = gastos

  // Datos de ejemplo - aquí conectarías con Firebase
  final double totalIncome = 8460.00;
  final double totalExpense = 677.00;
  late double totalBalance;

  @override
  void initState() {
    super.initState();
    totalBalance = totalIncome - totalExpense; // Ingresos menos gastos
  }

  final List<Map<String, dynamic>> transactions = [
    // Abril
    {
      'id': 1,
      'type': 'income',
      'category': 'Salario',
      'amount': 4000.00,
      'date': '30 de Abril',
      'description': 'Mensual',
      'iconName': 'trabajo',
      'month': 'Abril',
    },
    {
      'id': 2,
      'type': 'expense',
      'category': 'Supermercado',
      'amount': -100.00,
      'date': '24 de Abril',
      'description': 'Despensa',
      'iconName': 'supermercado',
      'month': 'Abril',
    },
    {
      'id': 3,
      'type': 'expense',
      'category': 'Alquiler',
      'amount': -674.40,
      'date': '15 de Abril',
      'description': 'Renta',
      'iconName': 'casa',
      'month': 'Abril',
    },
    {
      'id': 4,
      'type': 'expense',
      'category': 'Transporte',
      'amount': -4.13,
      'date': '08 de Abril',
      'description': 'Combustible',
      'iconName': 'transporte',
      'month': 'Abril',
    },
    {
      'id': 5,
      'type': 'income',
      'category': 'Otros',
      'amount': 520.00,
      'date': '24 de Abril',
      'description': 'Pagos',
      'iconName': 'pago',
      'month': 'Abril',
    },
    // Marzo
    {
      'id': 6,
      'type': 'income',
      'category': 'Salario',
      'amount': 4000.00,
      'date': '31 de Marzo',
      'description': 'Mensual',
      'iconName': 'trabajo',
      'month': 'Marzo',
    },
    {
      'id': 7,
      'type': 'income',
      'category': 'Otros',
      'amount': 340.00,
      'date': '15 de Marzo',
      'description': 'Ingresos',
      'iconName': 'aumento',
      'month': 'Marzo',
    },
    {
      'id': 8,
      'type': 'expense',
      'category': 'Comida',
      'amount': -70.40,
      'date': '31 de Marzo',
      'description': 'Cena',
      'iconName': 'comida',
      'month': 'Marzo',
    },
    // Febrero
    {
      'id': 9,
      'type': 'income',
      'category': 'Otros',
      'amount': 340.00,
      'date': '15 de Febrero',
      'description': 'Ingresos',
      'iconName': 'dinero',
      'month': 'Febrero',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BaseDesign(
      header: _HeaderAnalysis(),
      child: _buildTransactionContent(),
    );
  }

  Widget _buildTransactionContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildBalanceCard(),
          _buildTabButtons(),
          Expanded(
            child: _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.verdePalido,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            'Balance Total',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.verdeOscuro,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '\${balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              color: AppTheme.verdeOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.verde,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ingresos',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '\${totalIncome.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.verdeOscuro,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.azulPalido,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Gastos',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '\${totalExpense.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.verdeOscuro,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required double amount,
    required bool isIncome,
  }) {
    return Expanded(
      child: Container(
        height: 80, // Altura fija para que sean iguales
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40, // Ancho fijo
              height: 40, // Alto fijo
              decoration: BoxDecoration(
                color: isIncome ? AppTheme.verde : AppTheme.azulPalido,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.verdeOscuro,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTabButton('Ingresos', 'income'),
          SizedBox(width: 20),
          _buildTabButton('Gastos', 'expense'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, String filterType) {
    bool isSelected = selectedFilter == filterType;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            // Si ya está seleccionado, lo deselecciona (muestra todas las transacciones)
            // Si no está seleccionado, lo selecciona
            selectedFilter = isSelected ? null : filterType;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.azulOscuro : Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    List<Map<String, dynamic>> filteredTransactions = _getFilteredTransactions();
    Map<String, List<Map<String, dynamic>>> groupedTransactions = _groupTransactionsByMonth(filteredTransactions);
    
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: groupedTransactions.length,
        itemBuilder: (context, index) {
          String month = groupedTransactions.keys.elementAt(index);
          List<Map<String, dynamic>> monthTransactions = groupedTransactions[month]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado del mes
              Container(
                margin: EdgeInsets.only(bottom: 15, top: index == 0 ? 0 : 20),
                child: Text(
                  month,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.verdeOscuro,
                  ),
                ),
              ),
              // Transacciones del mes
              ...monthTransactions.map((transaction) => _buildTransactionItem(transaction)).toList(),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    if (selectedFilter == null) {
      // Mostrar todas las transacciones
      return transactions;
    } else {
      // Filtrar por tipo seleccionado
      return transactions.where((t) => t['type'] == selectedFilter).toList();
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupTransactionsByMonth(List<Map<String, dynamic>> transactions) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    
    // Definir el orden de los meses
    List<String> monthOrder = ['Abril', 'Marzo', 'Febrero', 'Enero', 'Diciembre', 'Noviembre', 'Octubre', 'Septiembre', 'Agosto', 'Julio', 'Junio', 'Mayo'];
    
    for (var transaction in transactions) {
      String month = transaction['month'];
      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }
      grouped[month]!.add(transaction);
    }
    
    // Ordenar por el orden de meses definido
    Map<String, List<Map<String, dynamic>>> sortedGrouped = {};
    for (String month in monthOrder) {
      if (grouped.containsKey(month)) {
        sortedGrouped[month] = grouped[month]!;
      }
    }
    
    return sortedGrouped;
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    bool isIncome = transaction['type'] == 'income';
    double amount = transaction['amount'];
    
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isIncome ? AppTheme.azulOscuro.withOpacity(0.1) : AppTheme.azulPalido.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              IconHelper.getIconFromString(transaction['iconName']),
              color: isIncome ? AppTheme.azulOscuro : AppTheme.azulPalido,
              size: 24,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['category'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.verdeOscuro,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaction['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      transaction['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : ''}\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? AppTheme.verde : AppTheme.azulOscuro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _HeaderAnalysis() {
    return Container(
      child: Column(
        children: [
          NavigationHeader(
            title: 'Transacciones',
            showNotifications: false, // Eliminado el botón de notificaciones
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}