import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:flutter/material.dart';


class AnalysisScreen extends StatelessWidget {
  static const name = 'analysis-screen';


  const AnalysisScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return BaseDesign(
      header: _HeaderAnalysis(),
      child: Placeholder(
        child: Center(
          child: Text(
            'Análisis de Gastos',
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
              title: 'Analisis',
              showNotifications: true,
            ),
            const SizedBox(height: 20),
            
          ],
        ),
      );
    }
  }