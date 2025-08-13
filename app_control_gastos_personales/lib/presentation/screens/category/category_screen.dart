import 'package:app_control_gastos_personales/presentation/screens/category/categorydetail_screen.dart';
import 'package:app_control_gastos_personales/presentation/screens/category/createcategory_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/presentation/widgets/navigation_header.dart';
import 'package:app_control_gastos_personales/presentation/widgets/category_card.dart';

import 'package:app_control_gastos_personales/application/controllers/category/category_controller.dart';
import 'package:app_control_gastos_personales/domain/entities/category.dart';

class CategoryScreen extends StatelessWidget {
  static const name = 'category-screen';
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());

    return BaseDesign(
      header: const _Header(),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<Category> items = controller.categories;

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.80,
          ),
          itemCount: items.length + 1, // +1 por el “More”
          itemBuilder: (context, index) {
            if (index < items.length) {
              final cat = items[index];
              return CategoryCard(
                category: cat,
                onTap: () =>
                    context.pushNamed(CategoryDetailScreen.name, extra: cat),
              );
            }

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                final created = await context.pushNamed<bool>(
                  CreateCategoryScreen.name,
                );
                if (created == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Categoría creada')),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.azulPalido,
                  border: Border.all(
                    color: AppTheme.azulOscuro.withOpacity(.15),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (contextLayout, c) {
                    final h = c.maxHeight;
                    final iconBox = (h * 0.52).clamp(36, 56).toDouble();
                    final gap = (h * 0.06).clamp(2, 8).toDouble();
                    final fontSize = (h * 0.15).clamp(10, 13).toDouble();
                    final ts = MediaQuery.textScaleFactorOf(
                      contextLayout,
                    ).clamp(1.0, 1.1);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: iconBox,
                        height: iconBox,
                        child: const Icon(Icons.add, size: 28, color: AppTheme.blancoPalido),
                      ),
                      SizedBox(height: gap),
                      Flexible(
                        child: MediaQuery(
                          data: MediaQuery.of(contextLayout).copyWith(textScaler: TextScaler.linear(ts)),
                          child: Text(
                            'More',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: AppTheme.verdeOscuro,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
        NavigationHeader(title: 'Categorias', showNotifications: false, showBackButton: false),
        SizedBox(height: 20),
      ],
    );
  }
}
