import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_control_gastos_personales/domain/entities/transaction.dart';
import 'package:app_control_gastos_personales/infrastucture/datasources/transaction_datasource.dart';
import 'package:app_control_gastos_personales/infrastucture/repositories/transaction_repository_impl.dart';
import 'package:app_control_gastos_personales/utils/session_controller.dart';

class CreateTransactionController extends GetxController {
  CreateTransactionController({
    required this.categoryId,
    required this.trantypeid, // 1=Income, 2=Expense
  });

  final String categoryId;
  final int trantypeid;

  final _datasource = TransactionDatasourceImpl(FirebaseFirestore.instance);
  late final _repo = TransactionRepositoryImpl(_datasource);

  final formKey = GlobalKey<FormState>();
  final amountCtrl = TextEditingController();
  final notesCtrl  = TextEditingController();

  final isSaving = false.obs;
  final date = DateTime.now().obs;

 Future<bool> pickDate(BuildContext context) async {
  // cierra el teclado antes de abrir el picker
  FocusScope.of(context).unfocus();

  final picked = await showDatePicker(
    context: context,
    initialDate: date.value,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    // locale: const Locale('es'), // si quieres forzar español
  );

  if (picked == null) return false;

  // Normaliza a medianoche local para evitar desfases por zona horaria
  final normalized = DateTime(picked.year, picked.month, picked.day);
  date.value = normalized;      // Obx se disparará
  // date.refresh(); // no es necesario, pero puedes dejarlo si quieres
  return true;
}

  Future<bool> save() async {
    if (!formKey.currentState!.validate()) return false;

    await SessionController.instance.loadSession();
    final uid = SessionController.instance.userId;
    if (uid == null || uid.isEmpty) {
      Get.snackbar('Sesión', 'No hay usuario en sesión.');
      return false;
    }

    final value = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
    if (value == null || value <= 0) {
      Get.snackbar('Monto', 'Ingresa un monto válido.');
      return false;
    }

    try {
      isSaving.value = true;

      final tx = TransactionEntity(
        id: '',
        userId: uid,
        categoryId: categoryId,
        trantypeid: trantypeid,
        amount: value,
        date: date.value,
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      );

      await _repo.create(tx);
      return true;
    } catch (e) {
      Get.snackbar('Transacciones', 'Error al guardar: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }

  
}
