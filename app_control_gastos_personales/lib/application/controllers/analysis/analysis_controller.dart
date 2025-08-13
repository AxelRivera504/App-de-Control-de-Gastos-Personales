import '/domain/entities/analysis.dart';
import '/domain/usecases/get_all_analyses.dart';

class AnalysisController {
    final GetAllAnalyses getAllAnalyses;

    List<Analysis> analyses = [];

    AnalysisController({required this.getAllAnalyses});

    Future<void> loadAnalyses() async {
    analyses = await getAllAnalyses();
    }
}
