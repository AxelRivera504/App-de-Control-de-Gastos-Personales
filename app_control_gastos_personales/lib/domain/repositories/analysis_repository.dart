import '../entities/analysis.dart';

abstract class AnalysisRepository {
  Future<List<Analysis>> getAllAnalyses();
  Future<Analysis> getAnalysisById(String id);
  Future<void> createAnalysis(Analysis analysis);
  Future<void> updateAnalysis(Analysis analysis);
  Future<void> deleteAnalysis(String id);
}
