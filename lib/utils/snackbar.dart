import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';

class CustomSnackBar {
  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = AppTheme.verde,
    Color textColor = AppTheme.verdeOscuro,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
