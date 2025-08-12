
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/domain/entities/analysis.dart';

class AnalysisDetailScreen extends StatelessWidget {
  static const name = 'analysis-detail-screen';
  const AnalysisDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Analysis analysis = GoRouterState.of(context).extra as Analysis;
    return Scaffold(
      backgroundColor: AppTheme.verde,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back, color: Colors.white)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(analysis.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const Icon(Icons.analytics, color: Colors.white),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.blancoPalido,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(48), topRight: Radius.circular(48)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.azulPalido,
                      child: analysis.iconCodePoint != null
                          ? Icon(IconData(analysis.iconCodePoint!, fontFamily: analysis.iconFontFamily), size: 40, color: AppTheme.azulOscuro)
                          : const Icon(Icons.analytics, color: AppTheme.azulOscuro),
                    ),
                    const SizedBox(height: 16),
                    Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.verdeOscuro)),
                    const SizedBox(height: 8),
                    Text(analysis.description ?? 'Sin descripción'),
                    const SizedBox(height: 12),
                    Text('Rango:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.verdeOscuro)),
                    const SizedBox(height: 8),
                    Text('${analysis.startDate?.toLocal().toString().split(' ')[0] ?? '-'}  →  ${analysis.endDate?.toLocal().toString().split(' ')[0] ?? '-'}'),
                    const Spacer(),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.verde, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generar reporte (pendiente)')));
                      },
                      child: const Text('Generar reporte', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
