import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';

mixin SnackBarMixin {
  void showSnackBar(BuildContext context, String message, {bool isSuccess = false}) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? AppTheme.verde : Colors.redAccent,
        ),
      );
    }
  }
}