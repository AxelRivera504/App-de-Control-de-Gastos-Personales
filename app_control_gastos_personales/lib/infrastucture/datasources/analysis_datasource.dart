import '/domain/entities/analysis.dart';

abstract class AnalysisDataSource {
  Future<List<Analysis>> fetchAnalyses();
  Future<Analysis> fetchAnalysis(String id);
  Future<void> insertAnalysis(Analysis analysis);
  Future<void> modifyAnalysis(Analysis analysis);
  Future<void> removeAnalysis(String id);
}
