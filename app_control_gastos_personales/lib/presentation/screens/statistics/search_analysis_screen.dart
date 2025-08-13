import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  
  // Datos de ejemplo - reemplazar con datos reales de tu base de datos
  final List<String> _categories = ['Comida', 'Transporte', 'Entretenimiento', 'Salud', 'Educación'];
  
  // Base de datos simulada de transacciones
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'title': 'Uber al trabajo',
      'category': 'Transporte',
      'date': DateTime(2025, 8, 13),
      'amount': 15.50,
      'type': 'expense',
      'icon': Icons.directions_car,
    },
    {
      'title': 'Bonus trabajo',
      'category': 'Trabajo',
      'date': DateTime(2025, 8, 13),
      'amount': 500.00,
      'type': 'income',
      'icon': Icons.work,
    },
    {
      'title': 'Almuerzo',
      'category': 'Comida',
      'date': DateTime(2025, 8, 15),
      'amount': 25.00,
      'type': 'expense',
      'icon': Icons.restaurant,
    },
    {
      'title': 'Metro',
      'category': 'Transporte',
      'date': DateTime(2025, 8, 15),
      'amount': 5.00,
      'type': 'expense',
      'icon': Icons.train,
    },
  ];

  void _performSearch() {
    setState(() {
      _hasSearched = true;
      _searchResults = _filterTransactions();
    });
  }

  List<Map<String, dynamic>> _filterTransactions() {
    List<Map<String, dynamic>> filtered = List.from(_allTransactions);

    // Filtro por texto de búsqueda
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction['title'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
               transaction['category'].toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // Filtro por categoría
    if (_selectedCategory != null) {
      filtered = filtered.where((transaction) {
        return transaction['category'] == _selectedCategory;
      }).toList();
    }

    // Filtro por fecha
    if (_selectedDate != null) {
      filtered = filtered.where((transaction) {
        DateTime transactionDate = transaction['date'];
        return transactionDate.year == _selectedDate!.year &&
               transactionDate.month == _selectedDate!.month &&
               transactionDate.day == _selectedDate!.day;
      }).toList();
    }

    // Filtro por tipo (Ingresos/Gastos)
    if (_selectedType != 'Todos') {
      String filterType = _selectedType == 'Ingresos' ? 'income' : 'expense';
      filtered = filtered.where((transaction) {
        return transaction['type'] == filterType;
      }).toList();
    }

    return filtered;
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
            _buildSearchButton(),
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
              'Search',
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
          hintText: 'Buscar...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
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
                'Seleccionar categoría',
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
              border: Border.all(color: AppTheme.verde),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null 
                    ? DateFormat('dd/MMM/yyyy').format(_selectedDate!)
                    : 'Seleccionar fecha',
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
          'Reporte',
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
            const SizedBox(width: 12),
            _buildReportOption('Gastos', Icons.trending_down, AppTheme.azulOscuro),
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
            _selectedType = isSelected ? 'Todos' : label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isSelected ? color : Colors.transparent,
                ),
                child: isSelected 
                  ? const Icon(Icons.check, color: Colors.white, size: 10)
                  : null,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _performSearch();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.verde,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Buscar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
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
              'Usa los filtros y presiona buscar',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
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
              'No se encontraron resultados',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otros filtros',
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
        final result = _searchResults[index];
        final isExpense = result['type'] == 'expense';
        
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
                  result['icon'],
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
                      result['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result['category']} • ${DateFormat('dd MMM yyyy').format(result['date'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isExpense ? '-' : '+'}\$${NumberFormat('#,##0.00').format(result['amount'])}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isExpense ? AppTheme.azulOscuro : AppTheme.verde,
                ),
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