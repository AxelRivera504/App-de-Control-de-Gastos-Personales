import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/domain/entities/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.azulOscuro,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (_, c) {
            final h = c.maxHeight;                  // alto disponible del tile
            final iconBox = (h * 0.55).clamp(40, 64).toDouble();
            final gap = (h * 0.06).clamp(4, 12).toDouble();
            final fontSize = (h * 0.16).clamp(10, 14).toDouble();

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconBox,
                  height: iconBox,
                  decoration: BoxDecoration(
                    color: AppTheme.azulOscuro.withOpacity(.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(category.iconData,
                      size: iconBox * 0.55, color: AppTheme.blancoPalido),
                ),
                SizedBox(height: gap),
                Flexible(
                  child: Text(
                    category.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: AppTheme.blancoPalido,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
