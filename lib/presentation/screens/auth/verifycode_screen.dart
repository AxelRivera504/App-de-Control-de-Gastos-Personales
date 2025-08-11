import 'package:app_control_gastos_personales/application/controllers/auth/verifycode_controller.dart';
import 'package:app_control_gastos_personales/infrastructure/services/email_service.dart';
import 'package:app_control_gastos_personales/presentation/screens/auth/resetpassword_screen.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/utils/snackbar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyCodeScreen extends StatelessWidget {
  static const name = 'verifycode-screen';
  final String email;
  VerifyCodeScreen({super.key, required this.email});
  final TextEditingController _pinController = TextEditingController();

  void _verifyCode(BuildContext context, VerifyCodeController verificodeController) async {
    final code = _pinController.text.trim();

    if (code.length != 6) {
      CustomSnackBar.show(
        context,
        "El código debe tener 6 dígitos",
        backgroundColor: AppTheme.anarajando,
        textColor: AppTheme.blancoPalido,
      );
      return;
    }

    final result = await verificodeController.verifyResetCode(email, code);

    if (result == true) {
      context.goNamed(
        ResetPasswordScreen.name,
        extra: {'email': email},
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

  void _resendCode(BuildContext context, VerifyCodeController verificodeController) async {
    final emailService = EmailService();
    final code = await verificodeController.generateRecoveryCode(email);
    if (code == null) {
      CustomSnackBar.show(
        context,
        "Error al generar el código",
        backgroundColor: AppTheme.anarajando,
      );
      return;
    }

    if (code == 'not_found') {
      CustomSnackBar.show(
        context,
        "Usuario no encontrado",
        backgroundColor: AppTheme.anarajando,
      );
      return;
    }

    if (code == 'inactive') {
      CustomSnackBar.show(
        context,
        "Cuenta desactivada",
        backgroundColor: AppTheme.anarajando,
      );
      return;
    }

    await emailService.sendRecoveryEmail(email, code);
    CustomSnackBar.show(context, "Se ha reenviado el código");
  }


  @override
  Widget build(BuildContext context) {
    final verifyCodeController = Get.put(VerifyCodeController());

    return BaseDesign(
      header: const Text(
        "Verificar Código",
        style: TextStyle(
          color: AppTheme.verdeOscuro,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Obx(
        () => Column(
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
        
            _buildPinCodeInput(context),
        
            const SizedBox(height: 40),
            verifyCodeController.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () => _verifyCode(context, verifyCodeController),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.verde,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text("Verificar", style: TextStyle(color: AppTheme.verdeOscuro, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            verifyCodeController.isLoadingRecoverCode.value
                ? const CircularProgressIndicator()
                : TextButton(
              onPressed: () => _resendCode(context, verifyCodeController),
              child: const Text("¿No recibiste el código? Reenviar", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.verdeOscuro)),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildPinCodeInput(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 320,
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

