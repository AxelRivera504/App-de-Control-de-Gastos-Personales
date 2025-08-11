import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final bool isPasswordField = widget.isPassword;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: isPasswordField ? _obscureText : false,
      keyboardType: widget.keyboardType,
      style: const TextStyle(color: Colors.grey, fontSize: 14),
      decoration: InputDecoration(
        fillColor: AppTheme.verdePalido,
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
