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
      
      // Obtener todas las categorías del usuario
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();

      print('Total categorías en BD: ${snapshot.docs.length}'); // Debug

      if (!mounted) return; // Verificar si el widget sigue montado

      categoriesCache.clear();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        // Debug: Imprimir todos los campos de cada categoría
        print('Categoría ID: ${doc.id}');
        print('Datos completos: $data');
        
        // Verificar diferentes posibles campos de usuario
        final userCreate = data['userCreate']?.toString();
        final userid = data['userid']?.toString();
        
        print('userCreate: "$userCreate", userid: "$userid", buscando: "$userId"');
        
        // Si pertenece al usuario actual
        if (userCreate == userId || userid == userId) {
          print('✓ Categoría válida para el usuario: ${data['description']}');
          
          categoriesCache[doc.id] = {
            'description': data['description']?.toString() ?? 'Categoría sin nombre',
            'iconCodePoint': data['iconCodePoint'] ?? Icons.category.codePoint,
            'iconFontFamily': data['iconFontFamily'] ?? 'MaterialIcons',
          };
        } else {
          print('✗ Categoría no pertenece al usuario');
        }
      }
      
      print('Categorías cargadas en cache: ${categoriesCache.length}');
      print('IDs en cache: ${categoriesCache.keys.toList()}');
      
    } catch (e) {
      print('Error cargando categorías: $e');
      print('StackTrace: ${StackTrace.current}');
    }
  }

  Future<void> _loadTransactions(String userId) async {
    try {
      print('Cargando transacciones para userId: $userId'); // Debug
      
      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userid', isEqualTo: userId)
          .get();

      print('Transacciones encontradas para userId "$userId": ${snapshot.docs.length}'); // Debug

      if (!mounted) return; // Verificar si el widget sigue montado

      final List<Map<String, dynamic>> loadedTransactions = [];
      double income = 0.0;
      double expense = 0.0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('=== Procesando transacción ${doc.id} ===');
        print('Data completa: $data');
        
        final categoryId = data['categoryid']?.toString() ?? '';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final trantypeid = (data['trantypeid'] as int?) ?? 1;
        
        print('CategoryId: "$categoryId"');
        print('Categorías disponibles en cache: ${categoriesCache.keys.toList()}');
        
        // Verificar si la fecha existe y es válida
        if (data['date'] == null) {
          print('Transacción sin fecha: ${doc.id}');
          continue;
        }
        
        final date = (data['date'] as Timestamp).toDate();
        
        // Obtener información de la categoría
        final categoryInfo = categoriesCache[categoryId];
        print('CategoryInfo encontrada: $categoryInfo');
        
        String categoryName;
        IconData iconData;
        
        if (categoryInfo != null) {
          categoryName = categoryInfo['description'] ?? 'Categoría sin nombre';
          iconData = IconData(
            categoryInfo['iconCodePoint'] ?? Icons.category.codePoint,
            fontFamily: categoryInfo['iconFontFamily'] ?? 'MaterialIcons',
          );
          print('✓ Categoría encontrada: $categoryName');
        } else {
          // Si no encontramos la categoría, buscarla directamente
          print('⚠ Categoría no encontrada en cache, buscando directamente...');
          try {
            final categoryDoc = await FirebaseFirestore.instance
                .collection('categories')
                .doc(categoryId)
                .get();
                
            if (categoryDoc.exists) {
              final catData = categoryDoc.data()!;
              categoryName = catData['description']?.toString() ?? 'Categoría sin nombre';
              iconData = IconData(
                catData['iconCodePoint'] ?? Icons.category.codePoint,
                fontFamily: catData['iconFontFamily'] ?? 'MaterialIcons',
              );
              print('✓ Categoría encontrada directamente: $categoryName');
              
              // Agregar al cache para futuras consultas
              categoriesCache[categoryId] = {
                'description': categoryName,
                'iconCodePoint': catData['iconCodePoint'] ?? Icons.category.codePoint,
                'iconFontFamily': catData['iconFontFamily'] ?? 'MaterialIcons',
              };
            } else {
              categoryName = 'Categoría eliminada';
              iconData = IconData(Icons.help_outline.codePoint, fontFamily: 'MaterialIcons');
              print('✗ Categoría no existe en BD');
            }
          } catch (e) {
            print('Error buscando categoría directamente: $e');
            categoryName = 'Error en categoría';
            iconData = IconData(Icons.error_outline.codePoint, fontFamily: 'MaterialIcons');
          }
        }

        final transaction = {
          'id': doc.id,
          'type': trantypeid == 1 ? 'income' : 'expense',
          'category': categoryName,
          'amount': trantypeid == 1 ? amount : -amount,
          'date': DateFormat('dd \'de\' MMMM', 'es').format(date),
          'description': data['notes']?.toString() ?? 'Sin descripción',
          'iconData': iconData,
          'month': DateFormat('MMMM', 'es').format(date),
          'rawDate': date,
        };

        loadedTransactions.add(transaction);
        print('✓ Transacción procesada: ${transaction['category']}');

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

      print('=== RESUMEN ===');
      print('Total transacciones procesadas: ${loadedTransactions.length}');
      print('Total ingresos: $income, Total gastos: $expense');
      print('Categorías utilizadas: ${loadedTransactions.map((t) => t['category']).toSet().toList()}');

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
          // Eliminamos los botones separados _buildTabButtons(),
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
              // Cuadro de Ingresos con funcionalidad de botón
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectedFilter = selectedFilter == 'income' ? null : 'income';
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedFilter == 'income' ? AppTheme.azulOscuro : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: selectedFilter == 'income' 
                          ? Border.all(color: AppTheme.azulOscuro, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: selectedFilter == 'income' 
                                ? Colors.white 
                                : AppTheme.verde,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_downward,
                            color: selectedFilter == 'income' 
                                ? AppTheme.verde 
                                : Colors.white,
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
                                  color: selectedFilter == 'income' 
                                      ? Colors.white 
                                      : Colors.grey[600],
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
                                    color: selectedFilter == 'income' 
                                        ? Colors.white 
                                        : AppTheme.verdeOscuro,
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
              ),
              SizedBox(width: 20),
              // Cuadro de Gastos con funcionalidad de botón
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectedFilter = selectedFilter == 'expense' ? null : 'expense';
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedFilter == 'expense' ? AppTheme.azulOscuro : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: selectedFilter == 'expense' 
                          ? Border.all(color: AppTheme.azulOscuro, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: selectedFilter == 'expense' 
                                ? Colors.white 
                                : AppTheme.azulPalido,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_upward,
                            color: selectedFilter == 'expense' 
                                ? AppTheme.azulPalido 
                                : Colors.white,
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
                                  color: selectedFilter == 'expense' 
                                      ? Colors.white 
                                      : Colors.grey[600],
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
                                    color: selectedFilter == 'expense' 
                                        ? Colors.white 
                                        : AppTheme.verdeOscuro,
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
              ),
            ],
          ),
        ],
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