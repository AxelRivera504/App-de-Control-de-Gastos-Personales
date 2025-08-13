import '../../domain/entities/analysis.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../datasources/analysis_datasource.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final AnalysisDatasource datasource;
  AnalysisRepositoryImpl(this.datasource);

  @override
  Future<void> createAnalysis(Analysis analysis) {
    return datasource.createAnalysis(analysis);
  }

  @override
  Future<Analysis?> getAnalysisById(String id) {
    return datasource.getAnalysisById(id);
  }

  @override
  Future<List<Analysis>> getAnalysesByUser(String userId) {
    return datasource.getAnalysesByUser(userId);
  }
}