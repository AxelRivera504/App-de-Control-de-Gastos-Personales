import '../entities/analysis.dart';
import '../repositories/analysis_repository.dart';

class CreateAnalysis {
  final AnalysisRepository repository;
  CreateAnalysis(this.repository);

  Future<void> call(Analysis analysis) async {
    return repository.createAnalysis(analysis);
  }
}