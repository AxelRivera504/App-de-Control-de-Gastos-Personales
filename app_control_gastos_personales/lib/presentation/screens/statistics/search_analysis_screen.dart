import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchAnalysisScreen extends StatefulWidget {
  static const name = 'search-analysis-screen';

  const SearchAnalysisScreen({super.key});

  @override
  State<SearchAnalysisScreen> createState() => _SearchAnalysisScreenState();
}

class _SearchAnalysisScreenState extends State<SearchAnalysisScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  String _selectedType = 'Todos'; // 'Ingresos', 'Gastos', 'Todos'
  List<Map<String, dynamic>> _searchResults = [];
  bool _hasSearched = false;
  bool _isLoading = false;
  
  // Lista de categorías - puedes cargarlas dinámicamente desde Firebase
  final List<String> _categories = [
    'Comida', 
    'Transporte', 
    'Entretenimiento', 
    'Salud', 
    'Educación',
    'Servicios',
    'Compras',
    'Otros'
  ];

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await _searchTransactions();
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _searchTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('date', descending: true);

    // Filtro por fecha si está seleccionada
    if (_selectedDate != null) {
      final startOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay));
    }

    // Filtro por categoría
    if (_selectedCategory != null) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    // Filtro por tipo (ingresos/gastos)
    if (_selectedType != 'Todos') {
      String typeFilter = _selectedType == 'Ingresos' ? 'income' : 'expense';
      query = query.where('type', isEqualTo: typeFilter);
    }

    final querySnapshot = await query.get();
    List<Map<String, dynamic>> results = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      
      // Filtro por texto de búsqueda (se hace en el cliente porque Firestore no tiene full-text search)
      if (_searchController.text.isNotEmpty) {
        final searchText = _searchController.text.toLowerCase();
        final title = (data['title'] ?? '').toString().toLowerCase();
        final description = (data['description'] ?? '').toString().toLowerCase();
        final category = (data['category'] ?? '').toString().toLowerCase();
        
        if (title.contains(searchText) || 
            description.contains(searchText) || 
            category.contains(searchText)) {
          results.add(data);
        }
      } else {
        results.add(data);
      }
    }

    return results;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedDate = null;
      _selectedType = 'Todos';
      _searchResults = [];
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseDesign(
      header: _buildHeader(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildCategoriesSection(),
            const SizedBox(height: 16),
            _buildDateSection(),
            const SizedBox(height: 16),
            _buildReportSection(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSearchButton()),
                const SizedBox(width: 12),
                _buildClearButton(),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 20, top: 8, bottom: 12),
      decoration: const BoxDecoration(
        color: AppTheme.verde,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Buscar Transacciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por título, descripción...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade400),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (value) {
          setState(() {}); // Para actualizar el botón de limpiar
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.blancoPalido,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.verde.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: Text(
                'Todas las categorías',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.verde),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppTheme.verde,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.blancoPalido,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedDate != null ? AppTheme.verde : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null 
                    ? DateFormat('dd/MMM/yyyy').format(_selectedDate!)
                    : 'Todas las fechas',
                  style: TextStyle(
                    color: _selectedDate != null ? Colors.black87 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.calendar_today, color: AppTheme.verde, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de transacción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildReportOption('Ingresos', Icons.trending_up, AppTheme.verde),
            const SizedBox(width: 8),
            _buildReportOption('Gastos', Icons.trending_down, AppTheme.azulOscuro),
            const SizedBox(width: 8),
            _buildReportOption('Todos', Icons.list, Colors.grey.shade600),
          ],
        ),
      ],
    );
  }

  Widget _buildReportOption(String label, IconData icon, Color color) {
    final isSelected = _selectedType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey.shade500,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _performSearch,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.verde,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Buscar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildClearButton() {
    return ElevatedButton(
      onPressed: _clearFilters,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: const Icon(Icons.clear_all),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.verde),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Configura tus filtros y presiona buscar',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Puedes buscar por texto, categoría, fecha o tipo',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron transacciones',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otros filtros de búsqueda',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final transaction = _searchResults[index];
        final isExpense = transaction['type'] == 'expense';
        final date = (transaction['date'] as Timestamp).toDate();
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isExpense ? AppTheme.azulOscuro : AppTheme.verde).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isExpense ? AppTheme.azulOscuro : AppTheme.verde,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['title'] ?? 'Sin título',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction['category'] ?? 'Sin categoría'} • ${DateFormat('dd MMM yyyy').format(date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (transaction['description'] != null && transaction['description'].isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        transaction['description'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isExpense ? '-' : '+'}\$${NumberFormat('#,##0.00').format(transaction['amount'] ?? 0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isExpense ? AppTheme.azulOscuro : AppTheme.verde,
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(date),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}