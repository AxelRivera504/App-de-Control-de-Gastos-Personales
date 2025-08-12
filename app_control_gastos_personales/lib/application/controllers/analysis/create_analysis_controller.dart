import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_control_gastos_personales/infrastucture/datasources/analysis_datasource.dart';
import 'package:app_control_gastos_personales/infrastucture/repositories/analysis_repository_impl.dart';
import '../../../domain/usecases/create_analysis.dart';
import '../../../utils/session_controller.dart';
import '../../../domain/entities/analysis.dart';

class CreateAnalysisController extends GetxController {
  final _datasource = AnalysisDatasourceImpl(FirebaseFirestore.instance);
  late final _repository = AnalysisRepositoryImpl(_datasource);
  late final _createAnalysis = CreateAnalysis(_repository);

  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  final isSaving = false.obs;
  IconData? pickedIcon;

  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    startDate.value = DateTime.now();
    endDate.value = DateTime.now();
  }

  Future<bool> save() async {
    await SessionController.instance.loadSession();
    if (!formKey.currentState!.validate()) return false;

    final uid = SessionController.instance.userId;
    if (uid == null || uid.isEmpty) {
      Get.snackbar('Sesión', 'No hay usuario en sesión.');
      return false;
    }
    if (pickedIcon == null) {
      Get.snackbar('Ícono', 'Elige un ícono para el análisis.');
      return false;
    }
    if (startDate.value == null || endDate.value == null) {
      Get.snackbar('Fechas', 'Selecciona las fechas.');
      return false;
    }
    if (endDate.value!.isBefore(startDate.value!)) {
      Get.snackbar('Fechas', 'La fecha fin no puede ser antes de la inicio.');
      return false;
    }

    try {
      isSaving.value = true;
      final icon = pickedIcon!;
      final analysis = Analysis(
        id: '',
        title: titleCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        startDate: startDate.value,
        endDate: endDate.value,
        userCreate: uid,
        createDate: null,
        iconCodePoint: icon.codePoint,
        iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
        iconFontPackage: icon.fontPackage,
      );
      await _createAnalysis(analysis);
      return true;
    } catch (e) {
      Get.snackbar('Análisis', 'Error al guardar: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}