import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/analysis.dart';
import 'package:app_control_gastos_personales/infrastucture/datasources/analysis_datasource.dart';
import 'package:app_control_gastos_personales/infrastucture/repositories/analysis_repository_impl.dart';
import '../../../domain/usecases/get_analyses.dart';
import '../../../utils/session_controller.dart';

class AnalysisController extends GetxController {
    final _datasource = AnalysisDatasourceImpl(FirebaseFirestore.instance);
    late final _repository = AnalysisRepositoryImpl(_datasource);
    late final _getAnalyses = GetAnalyses(_repository);

    final isLoading = true.obs;
    final analyses = <Analysis>[].obs;

    @override
    void onInit() {
    super.onInit();
    loadAnalyses();
    }

    Future<void> loadAnalyses() async {
    try {
        isLoading.value = true;
        await SessionController.instance.loadSession();
        final uid = SessionController.instance.userId;
        if (uid == null || uid.isEmpty) {
        analyses.clear();
        return;
        }
        final list = await _getAnalyses(uid);
        analyses.assignAll(list);
    } catch (e) {
        Get.snackbar('Análisis', 'No se pudieron cargar los análisis: $e');
    } finally {
        isLoading.value = false;
    }
    }
}