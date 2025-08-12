import 'dart:async';
import 'package:app_control_gastos_personales/infrastucture/datasources/category_datasource.dart';
import 'package:app_control_gastos_personales/infrastucture/repositories/category_repository_impl.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_control_gastos_personales/domain/entities/category.dart';
import 'package:app_control_gastos_personales/domain/usecases/get_categories_stream.dart';

import 'package:app_control_gastos_personales/utils/session_controller.dart';

class CategoryController extends GetxController {
  final categories = <Category>[].obs;
  final isLoading = true.obs;

  StreamSubscription<List<Category>>? _sub;
  String? _uid;

  final _datasource = CategoryDatasourceImpl(FirebaseFirestore.instance);
  late final _repo = CategoryRepositoryImpl(_datasource);
  late final _getStream = GetCategoriesStream(_repo);

  @override
  void onInit() {
    super.onInit();
    _uid = SessionController.instance.userId;
    _subscribe();
  }

  void _subscribe() {
    _sub?.cancel();
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      isLoading.value = false;
      categories.clear();
      return;
    }
    isLoading.value = true;
    _sub = _getStream(uid).listen(
      (list) {
        categories.assignAll(list);
        isLoading.value = false;
      },
      onError: (_) => isLoading.value = false,
    );
  }

  /// Llama esto cuando cambie de usuario (login/logout).
  void setUser(String? uid) {
    _uid = uid;
    _subscribe();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}

