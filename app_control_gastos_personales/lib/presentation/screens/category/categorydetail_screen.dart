import 'package:app_control_gastos_personales/presentation/screens/transaction/createtransaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/domain/entities/category.dart';

class CategoryDetailScreen extends StatelessWidget {
  static const name = 'category-detail-screen';
  const CategoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Category category = GoRouterState.of(context).extra as Category;
    final isIncome = category.defaultTypeId == 1;

    return Scaffold(
      backgroundColor: AppTheme.verde,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.description,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications_none, color: Colors.white),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.blancoPalido,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(48), topRight: Radius.circular(48),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.azulPalido,
                            child: Icon(category.iconData, color: AppTheme.azulOscuro),
                          ),
                          const SizedBox(width: 10),
                          Text('ID: ${category.id}',
                              style: const TextStyle(color: AppTheme.verdeOscuro)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const Expanded(child: SizedBox()),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.verde,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          context.pushNamed(
                            CreateTransactionScreen.name,
                            extra: {
                              'categoryId': category.id,
                              'trantypeid': category.defaultTypeId, // 1 o 2
                              'categoryName': category.description,
                            },
                          );
                        },
                        child: Text(
                          isIncome ? 'Añadir Ingreso' : 'Añadir Egreso',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
