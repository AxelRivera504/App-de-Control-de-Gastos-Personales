import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';

mixin CustomSnackBarMixin {
  void showCustomSnackBar(
    BuildContext context,
    String message, {
    bool isSuccess = false,
    Color? backgroundColor,
    Color? textColor,
  }) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor ?? 
              (isSuccess ? AppTheme.verde : Colors.redAccent),
          content: Text(
            message,
            style: TextStyle(
              color: textColor ?? 
                  (isSuccess ? Colors.white : Colors.white),
            ),
          ),
        ),
      );
    }
  }
}