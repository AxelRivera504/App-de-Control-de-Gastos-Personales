import 'package:app_control_gastos_personales/application/controllers/category/category_detail_controller.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/domain/entities/category.dart';
import 'package:app_control_gastos_personales/presentation/screens/transaction/createtransaction_screen.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class CategoryDetailScreen extends StatelessWidget {
  static const name = 'category-detail-screen';
  const CategoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Category category = GoRouterState.of(context).extra as Category;
    final isIncome = category.defaultTypeId == 1;

    if (Get.isRegistered<CategoryDetailController>()) {
      Get.delete<CategoryDetailController>(force: true);
    }
    final c = Get.put(CategoryDetailController(
      categoryId: category.id,
      defaultTypeId: category.defaultTypeId,
    ));

    return BaseDesign(
      header: _CategoryHeader(
        title: category.description,
        icon: category.iconData,
        isIncome: isIncome,
        c: c,
      ),
      child: Obx(() {
        if (c.isLoading.value) return const Center(child: CircularProgressIndicator());

        if (c.groups.isEmpty) {
          // 👇 Sin el bloque del ID
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(),
              const Spacer(),
              _AddButton(isIncome: isIncome, category: category),
            ],
          );
        }

        return Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: c.groups.length,
                itemBuilder: (_, i) {
                  final g = c.groups[i];
                  final totalStr = g.total.toStringAsFixed(2);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(g.label, style: const TextStyle(
                            fontWeight: FontWeight.w700, color: AppTheme.verdeOscuro)),
                          const Spacer(),
                          Text(
                            (g.total >= 0 ? '+\$' : '-\$') + totalStr.replaceFirst('-', ''),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: g.total >= 0 ? AppTheme.verde : AppTheme.azulOscuro,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...g.items.map((t) {
                        final hh = t.date.hour.toString().padLeft(2,'0');
                        final mm = t.date.minute.toString().padLeft(2,'0');
                        final day = t.date.day.toString().padLeft(2,'0');
                        final mon = t.date.month.toString().padLeft(2,'0');
                        final sign = t.trantypeid == 1 ? '+' : '-';
                        final color = t.trantypeid == 1 ? AppTheme.verde : AppTheme.azulOscuro;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.azulPalido,
                            child: Icon(Icons.receipt_long, color: AppTheme.blancoPalido),
                          ),
                          title: Text(
                            t.notes ?? (t.trantypeid == 1 ? 'Ingreso' : 'Egreso'),
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.verdeOscuro),
                          ),
                          subtitle: Text('$day/$mon  •  $hh:$mm',
                              style: TextStyle(color: (t.trantypeid == 1 ? AppTheme.verde : AppTheme.azulOscuro) )),
                          trailing: Text(
                            '$sign\$${t.amount.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.w800, color: color),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
            _AddButton(isIncome: isIncome, category: category),
          ],
        );
      }),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isIncome;
  final CategoryDetailController c;

  const _CategoryHeader({
    required this.title,
    required this.icon,
    required this.isIncome,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => GoRouter.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.blancoPalido, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Obx(() {
            final amount = isIncome ? c.totalIncome.value : c.totalExpense.value;
            final label  = isIncome ? 'Total Ingresos' : 'Total Egresos';
            final sign   = isIncome ? '+' : '-';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.blancoPalido,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isIncome ? AppTheme.verde : AppTheme.azulOscuro,
                    child: Icon(icon, color: AppTheme.blancoPalido),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: isIncome ? AppTheme.verde : AppTheme.azulOscuro,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$sign\$${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isIncome ? AppTheme.verde : AppTheme.azulOscuro,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool isIncome;
  final Category category;
  const _AddButton({required this.isIncome, required this.category});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.verde,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
      onPressed: () {
        context.pushNamed(
          CreateTransactionScreen.name,
          extra: {
            'categoryId': category.id,
            'trantypeid': category.defaultTypeId,
            'categoryName': category.description,
          },
        );
      },
      child: Text(
        isIncome ? 'Añadir Ingreso' : 'Añadir Egreso',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}