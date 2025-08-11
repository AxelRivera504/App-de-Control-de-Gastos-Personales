import 'package:get/get.dart';
import 'package:app_control_gastos_personales/domain/category/category.dart';
import 'package:app_control_gastos_personales/infrastructure/category/category_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository _repository;
  var categories = <Category>[].obs;
  var isLoading = false.obs;

  CategoryController(this._repository);

  void loadCategories(String userId) {
    isLoading.value = true;
    _repository.getCategoriesByUser(userId).listen((data) {
      categories.assignAll(data);
      isLoading.value = false;
    });
  }

  Future<void> addCategory(Category category) async {
    await _repository.addCategory(category);
  }

  Future<void> updateCategory(String id, Category category) async {
    await _repository.updateCategory(id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
  }
}
