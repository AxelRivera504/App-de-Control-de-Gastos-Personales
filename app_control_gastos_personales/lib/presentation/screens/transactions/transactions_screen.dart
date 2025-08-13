import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:flutter/material.dart';


class TransactionsScreen extends StatelessWidget {
  static const name = 'transactions-screen';


  const TransactionsScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return BaseDesign(
      header: _HeaderAnalysis(),
      child: Placeholder(
        child: Center(
          child: Text(
            'transacciones de Gastos',
            style: TextStyle(
              fontSize: 24,
              color: AppTheme.verdeOscuro,
            ),
          ),
        ),
      ),
    );
  }

  
}

class _HeaderAnalysis extends StatelessWidget {
    const _HeaderAnalysis();
  
    @override
    Widget build(BuildContext context) {
      return Container(
        child: Column(
          children: [
            NavigationHeader(
              title: 'Transacciones',
              showNotifications: true,
            ),
            const SizedBox(height: 20),
            
          ],
        ),
      );
    }
  }