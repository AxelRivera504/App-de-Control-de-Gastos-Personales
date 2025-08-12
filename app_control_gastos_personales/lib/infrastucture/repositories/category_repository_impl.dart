import 'package:app_control_gastos_personales/domain/entities/category.dart';
import 'package:app_control_gastos_personales/domain/repositories/category_repository.dart';
import 'package:app_control_gastos_personales/infrastucture/datasources/category_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDatasource datasource;
  CategoryRepositoryImpl(this.datasource);

  @override
  Stream<List<Category>> streamActiveByUser(String uid) =>
      datasource.streamActiveByUser(uid);

  @override
  Future<String> create(Category category) => datasource.create(category);
}
