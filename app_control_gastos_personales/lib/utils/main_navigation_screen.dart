import 'package:app_control_gastos_personales/presentation/screens/category/category_screen.dart';
import 'package:app_control_gastos_personales/presentation/screens/statistics/analysis_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/screens/home_screen.dart';
import 'package:app_control_gastos_personales/presentation/screens/profile/profile_screen.dart';
import 'package:app_control_gastos_personales/presentation/screens/transactions/transactions_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  static const name = 'main-navigation-screen';
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavBarTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          HomeScreen(),
          AnalysisScreen(), // Estadísticas Transacciones
          TransactionsScreen(), // Resumen
          CategoryScreen(), // Transacciones
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.blancoPalido,
        selectedItemColor: AppTheme.verdeOscuro,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 32,
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transacciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: 'Categorías',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
