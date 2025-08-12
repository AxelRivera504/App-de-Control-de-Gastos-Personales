import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';

import 'package:app_control_gastos_personales/application/controllers/analysis/analysis_controller.dart';
import 'package:app_control_gastos_personales/domain/entities/analysis.dart';
import 'analysis_detail_screen.dart';
import 'create_analysis_screen.dart';

class AnalysisScreen extends StatelessWidget {
  static const name = 'analysis-screen';
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalysisController());

    return BaseDesign(
      header: const _Header(),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<Analysis> items = controller.analyses;

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.80,
          ),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index < items.length) {
              final a = items[index];
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.pushNamed(AnalysisDetailScreen.name, extra: a),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.azulPalido,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.azulOscuro.withOpacity(.15)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (a.iconCodePoint != null)
                        Icon(IconData(a.iconCodePoint!, fontFamily: a.iconFontFamily), size: 36, color: AppTheme.verdeOscuro)
                      else
                        Icon(Icons.analytics, size: 36, color: AppTheme.verdeOscuro),
                      const SizedBox(height: 8),
                      Text(
                        a.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.verdeOscuro, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }

            // "More"
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                final created = await context.pushNamed<bool>(CreateAnalysisScreen.name);
                if (created == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Análisis creado')));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.azulPalido,
                  border: Border.all(color: AppTheme.azulOscuro.withOpacity(.15)),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, size: 28, color: AppTheme.blancoPalido),
                    SizedBox(height: 8),
                    Text('More', style: TextStyle(color: AppTheme.verdeOscuro, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        NavigationHeader(title: 'Análisis', showNotifications: true),
        SizedBox(height: 20),
      ],
    );
  }
}