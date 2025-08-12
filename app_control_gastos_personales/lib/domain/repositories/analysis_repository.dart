import '../entities/analysis.dart';

abstract class AnalysisRepository {
  Future<void> createAnalysis(Analysis analysis);
  Future<List<Analysis>> getAnalysesByUser(String userId);
  Future<Analysis?> getAnalysisById(String id);
}