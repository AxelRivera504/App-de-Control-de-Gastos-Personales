import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesStream {
  final CategoryRepository repository;
  GetCategoriesStream(this.repository);

  Stream<List<Category>> call(String uid) {
    return repository.streamActiveByUser(uid);
  }
}
