import '../entities/analysis.dart';
import '../repositories/analysis_repository.dart';

class GetAnalyses {
  final AnalysisRepository repository;
  GetAnalyses(this.repository);

  Future<List<Analysis>> call(String userId) async {
    return repository.getAnalysesByUser(userId);
  }
}