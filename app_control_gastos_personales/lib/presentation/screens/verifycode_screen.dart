
import 'package:app_control_gastos_personales/infrastucture/datasources/user_datasource.dart';
import 'package:app_control_gastos_personales/presentation/screens/resetpassword_screen.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/utils/snackbar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';


class VerifyCodeScreen extends StatefulWidget {
  static const name = 'verifycode-screen';
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreentate();
}

class _VerifyCodeScreentate extends State<VerifyCodeScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  void _verifyCode() async {
  final code = _pinController.text.trim();

  if (code.length != 6) {
    if (!mounted) return;
    CustomSnackBar.show(
      context,
      "El código debe tener 6 dígitos",
      backgroundColor: AppTheme.anarajando,
      textColor: AppTheme.blancoPalido,
    );
    return;
  }

  final result = await UserDataSource().verifyResetCode(widget.email, code);

  if (result == true) {
    context.goNamed(
      ResetPasswordScreen.name,
      extra: {'email': widget.email},
    );
  } else {
    CustomSnackBar.show(
      context,
      "Código inválido o expirado",
      backgroundColor: AppTheme.anarajando,
      textColor: AppTheme.blancoPalido,
    );
  }
}

  

Future enviarEmail(String email, String codigo) async {
  final response = await http.post(
    Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
    headers: {
      'Content-Type': 'application/json',
      'origin': 'http://localhost'
    },
    body: json.encode({
      "service_id": dotenv.env['EMAILJS_SERVICE_ID'],
      "template_id": dotenv.env['EMAILJS_TEMPLATE_ID'],
      "user_id": dotenv.env['EMAILJS_USER_ID'],
      "template_params": {
        "email": email,
        "code": codigo
      }
    }),
  );

  return response.statusCode;
}



  @override
  Widget build(BuildContext context) {
    return BaseDesign(
      header: const Text(
        "Verificar Código",
        style: TextStyle(
          color: AppTheme.verdeOscuro,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "Introduce el código de verificación",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.verdeOscuro,
            ),
          ),
          const SizedBox(height: 20),
      
          // Aquí podrías usar un paquete como pin_code_fields
          _buildPinCodeInput(),
      
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.verde,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text("Aceptar", style: TextStyle(color: AppTheme.verdeOscuro, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              final userRepository = UserDataSource();
              final code = await userRepository.generateRecoveryCode(widget.email);
              await enviarEmail(widget.email, code!);
              CustomSnackBar.show(context, "Se ha reenviado el código");
            },
            child: const Text("Reenviar Código", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

Widget _buildPinCodeInput() {
  return Center(
    child: SizedBox(
      width: 320, // puedes ajustar entre 300–340 para 6 dígitos
      child: PinCodeTextField(
        controller: _pinController,
        appContext: context,
        length: 6,
        obscureText: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.circle,
          borderRadius: BorderRadius.circular(5),
          fieldHeight: 50,
          fieldWidth: 45,
          activeFillColor: AppTheme.verdePalido,
          inactiveFillColor: AppTheme.verdePalido,
          selectedFillColor: Colors.white,
          activeColor: AppTheme.verdeOscuro,
          selectedColor: AppTheme.verde,
          inactiveColor: AppTheme.verdePalido,
        ),
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Colors.transparent,
        enableActiveFill: true,
        onCompleted: (value) {},
        onChanged: (value) {},
      ),
    ),
  );
}



}

