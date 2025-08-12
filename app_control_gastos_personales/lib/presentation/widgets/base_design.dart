import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BaseDesign extends StatelessWidget {
  final String? title;
  final Widget? header;
  final Widget child;
  final double spaceHeader;

  const BaseDesign({
    super.key,
    this.title,
    this.header,
    required this.child,
    this.spaceHeader = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppTheme.verde),
        child: Column(
          children: [
            SizedBox(height: spaceHeader),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: header ??
                  (title != null
                      ? Text(
                          title!,
                          style: const TextStyle(
                            color: AppTheme.verdeOscuro,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox.shrink()),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.blancoPalido,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(48),
                    topRight: Radius.circular(48),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: child, // <- aquí tus listas/grids hacen su propio scroll
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
