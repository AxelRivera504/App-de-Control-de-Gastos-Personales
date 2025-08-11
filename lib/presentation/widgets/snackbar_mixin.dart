import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';

mixin SnackBarMixin {
  void showSnackBar(
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
          content: Text(
            message,
            style: TextStyle(
              color: textColor ?? Colors.white,
            ),
          ),
          backgroundColor: backgroundColor ?? 
              (isSuccess ? AppTheme.verde : Colors.redAccent),
        ),
      );
    }
  }
}