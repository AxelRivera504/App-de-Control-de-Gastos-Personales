import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  static const name = 'transactions-screen';

  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? selectedFilter;
  bool isLoading = true;
  
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double totalBalance = 0.0;
  
  List<Map<String, dynamic>> transactions = [];
  Map<String, Map<String, dynamic>> categoriesCache = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Cargar la sesión primero
    await SessionController.instance.loadSession();
    final userId = SessionController.instance.userId;
    print('UserId obtenido: $userId'); // Debug
    
    if (userId == null || userId.isEmpty) {
      print('Error: UserId es null o vacío');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    if (!mounted) return; // Verificar si el widget sigue montado

    setState(() {
      isLoading = true;
    });

    try {
      // Cargar categorías del usuario específico
      await _loadCategories(userId);
      
      // Cargar transacciones del usuario específico
      await _loadTransactions(userId);
      
    } catch (e) {
      print('Error cargando datos: $e');
    } finally {
      if (mounted) { // Verificar antes de setState
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCategories(String userId) async {
    try {
      print('Cargando categorías para userId: $userId'); // Debug
      
      // Buscar categorías que pertenezcan al usuario específico
      // Cambiado de 'userid' a 'userCreate' según tu modelo Category
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('userCreate', isEqualTo: userId) // Cambio aquí
          .get();

      print('Categorías encontradas: ${snapshot.docs.length}'); // Debug

      if (!mounted) return; // Verificar si el widget sigue montado

      categoriesCache.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('Categoría cargada: ${doc.id} - ${data['description']}'); // Debug
        
        categoriesCache[doc.id] = {
          'description': data['description'] ?? 'Sin categoría',
          'iconCodePoint': data['iconCodePoint'] ?? Icons.category.codePoint,
          'iconFontFamily': data['iconFontFamily'] ?? 'MaterialIcons',
        };
      }
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }

  Future<void> _loadTransactions(String userId) async {
    try {
      print('Cargando transacciones para userId: $userId'); // Debug
      
      // Debug: Verificar todas las transacciones primero
      final allSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .get();
      
      print('=== DEBUG: TODAS LAS TRANSACCIONES ===');
      for (final doc in allSnapshot.docs) {
        final data = doc.data();
        print('ID: ${doc.id}, userid: "${data['userid']}", categoryid: ${data['categoryid']}');
      }
      print('=== FIN DEBUG ===');
      
      // Removemos el orderBy temporalmente para evitar el error del índice
      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userid', isEqualTo: userId)
          .get(); // Sin orderBy por ahora

      print('Transacciones encontradas para userId "$userId": ${snapshot.docs.length}'); // Debug

      if (!mounted) return; // Verificar si el widget sigue montado

      final List<Map<String, dynamic>> loadedTransactions = [];
      double income = 0.0;
      double expense = 0.0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('Procesando transacción: ${doc.id}'); // Debug
        print('Data de transacción: $data'); // Debug
        
        final categoryId = data['categoryid'] as String? ?? '';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final trantypeid = (data['trantypeid'] as int?) ?? 1;
        
        // Verificar si la fecha existe y es válida
        if (data['date'] == null) {
          print('Transacción sin fecha: ${doc.id}');
          continue;
        }
        
        final date = (data['date'] as Timestamp).toDate();
        
        // Obtener información de la categoría
        final categoryInfo = categoriesCache[categoryId];
        final categoryName = categoryInfo?['description'] ?? 'Categoría no encontrada';
        
        print('Categoría para $categoryId: $categoryName'); // Debug
        
        // Crear el IconData desde la información almacenada
        final iconData = IconData(
          categoryInfo?['iconCodePoint'] ?? Icons.category.codePoint,
          fontFamily: categoryInfo?['iconFontFamily'] ?? 'MaterialIcons',
        );

        final transaction = {
          'id': doc.id,
          'type': trantypeid == 1 ? 'income' : 'expense',
          'category': categoryName,
          'amount': trantypeid == 1 ? amount : -amount,
          'date': DateFormat('dd \'de\' MMMM', 'es').format(date),
          'description': data['notes'] ?? 'Sin descripción',
          'iconData': iconData,
          'month': DateFormat('MMMM', 'es').format(date),
          'rawDate': date,
        };

        loadedTransactions.add(transaction);

        // Calcular totales
        if (trantypeid == 1) {
          income += amount;
        } else {
          expense += amount;
        }
      }

      // Ordenar manualmente por fecha (más reciente primero)
      loadedTransactions.sort((a, b) {
        final dateA = a['rawDate'] as DateTime;
        final dateB = b['rawDate'] as DateTime;
        return dateB.compareTo(dateA);
      });

      print('Total transacciones procesadas: ${loadedTransactions.length}'); // Debug
      print('Total ingresos: $income, Total gastos: $expense'); // Debug

      if (mounted) { // Verificar antes de setState
        setState(() {
          transactions = loadedTransactions;
          totalIncome = income;
          totalExpense = expense;
          totalBalance = income - expense;
        });
      }

    } catch (e) {
      print('Error cargando transacciones: $e');
      print('Stack trace: ${StackTrace.current}'); // Debug más detallado
    }
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseDesign(
      header: _HeaderAnalysis(),
      child: _buildTransactionContent(),
    );
  }

  Widget _buildTransactionContent() {
    if (isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.verde),
        ),
      );
    }

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
            '\$${totalBalance.toStringAsFixed(2)}',
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
                                '\$${totalIncome.toStringAsFixed(2)}',
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
                                '\$${totalExpense.toStringAsFixed(2)}',
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
          if (mounted) {
            setState(() {
              selectedFilter = isSelected ? null : filterType;
            });
          }
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
    
    if (groupedTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay transacciones',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera categoría y transacción',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    
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
              ...monthTransactions.map((transaction) => _buildTransactionItem(transaction)),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    if (selectedFilter == null) {
      return transactions;
    } else {
      return transactions.where((t) => t['type'] == selectedFilter).toList();
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupTransactionsByMonth(List<Map<String, dynamic>> transactions) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (var transaction in transactions) {
      String month = transaction['month'];
      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }
      grouped[month]!.add(transaction);
    }
    
    // Ordenar por fecha más reciente
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = grouped[a]![0]['rawDate'] as DateTime;
        final dateB = grouped[b]![0]['rawDate'] as DateTime;
        return dateB.compareTo(dateA);
      });
    
    Map<String, List<Map<String, dynamic>>> sortedGrouped = {};
    for (String month in sortedKeys) {
      sortedGrouped[month] = grouped[month]!;
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
              transaction['iconData'] ?? Icons.category,
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
                    Expanded(
                      child: Text(
                        transaction['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
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
            showNotifications: false,
            showBackButton: false
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}