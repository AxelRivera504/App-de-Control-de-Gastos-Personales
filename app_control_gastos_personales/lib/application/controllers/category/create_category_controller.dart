import 'package:app_control_gastos_personales/domain/entities/transactiontype.dart';
import 'package:app_control_gastos_personales/infrastucture/datasources/category_datasource.dart';
import 'package:app_control_gastos_personales/infrastucture/repositories/category_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/session_controller.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/usecases/create_category.dart';

class CreateCategoryController extends GetxController {
  final _datasource = CategoryDatasourceImpl(FirebaseFirestore.instance);
  late final _repository = CategoryRepositoryImpl(_datasource);
  late final _createCategory = CreateCategory(_repository);

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();

  final isSaving = false.obs;
  final state = true.obs;
  IconData? pickedIcon;

  final types = <TransactionType>[].obs;
  final selectedTypeId = 1.obs; 
  final loadingTypes = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    try {
      loadingTypes.value = true;
      final snap = await FirebaseFirestore.instance
          .collection('transactiontypes')
          .orderBy('trantypeid')
          .get();

      final list = snap.docs.map((d) {
        final m = d.data();
        return TransactionType(
          docId: d.id,
          typeId: (m['trantypeid'] as num).toInt(),
          description: (m['description'] ?? '').toString(),
        );
      }).toList();

      types.assignAll(list);
      if (list.isNotEmpty) selectedTypeId.value = list.first.typeId;
    } catch (e) {
      Get.snackbar('Tipos', 'No se pudieron cargar los tipos: $e');
    } finally {
      loadingTypes.value = false;
    }
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
      Get.snackbar('Ícono', 'Elige un ícono para la categoría.');
      return false;
    }

    try {
      isSaving.value = true;

      final icon = pickedIcon!;
      final category = Category(
        id: '',
        description: nameCtrl.text.trim(),
        state: state.value,
        userCreate: uid,
        createDate: null,
        iconCodePoint: icon.codePoint,
        iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
        iconFontPackage: icon.fontPackage,
        defaultTypeId: selectedTypeId.value
      );

      await _createCategory(category);
      return true;
    } catch (e) {
      Get.snackbar('Categorías', 'Error al guardar: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    super.onClose();
  }
}
