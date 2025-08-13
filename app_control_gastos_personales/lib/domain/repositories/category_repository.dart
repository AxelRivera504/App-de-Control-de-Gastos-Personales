import 'package:app_control_gastos_personales/domain/entities/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> streamActiveByUser(String uid);
  Future<String> create(Category category);
}
