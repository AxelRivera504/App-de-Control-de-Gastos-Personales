import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/analysis.dart';

abstract class AnalysisDatasource {
  Future<void> createAnalysis(Analysis analysis);
  Future<List<Analysis>> getAnalysesByUser(String userId);
  Future<Analysis?> getAnalysisById(String id);
}

class AnalysisDatasourceImpl implements AnalysisDatasource {
  final FirebaseFirestore firestore;
  AnalysisDatasourceImpl(this.firestore);

  CollectionReference get _col => firestore.collection('analyses');

  @override
  Future<void> createAnalysis(Analysis analysis) async {
    final doc = _col.doc();
    final map = {
      'title': analysis.title,
      'description': analysis.description,
      'startDate': analysis.startDate != null ? Timestamp.fromDate(analysis.startDate!) : null,
      'endDate': analysis.endDate != null ? Timestamp.fromDate(analysis.endDate!) : null,
      'userCreate': analysis.userCreate,
      'createDate': Timestamp.now(),
      'iconCodePoint': analysis.iconCodePoint,
      'iconFontFamily': analysis.iconFontFamily,
      'iconFontPackage': analysis.iconFontPackage,
    };
    map.removeWhere((k, v) => v == null);
    await doc.set(map);
  }

  @override
  Future<List<Analysis>> getAnalysesByUser(String userId) async {
    final snap = await _col.where('userCreate', isEqualTo: userId).orderBy('createDate', descending: true).get();
    final list = snap.docs.map((d) {
      final m = d.data() as Map<String, dynamic>;
      final start = (m['startDate'] as Timestamp?)?.toDate();
      final end = (m['endDate'] as Timestamp?)?.toDate();
      final create = (m['createDate'] as Timestamp?)?.toDate();
      final mapped = {
        ...m,
        'startDate': start,
        'endDate': end,
        'createDate': create,
      };
      return Analysis.fromMap(d.id, mapped);
    }).toList();
    return list;
  }

  @override
  Future<Analysis?> getAnalysisById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    final m = doc.data() as Map<String, dynamic>;
    final start = (m['startDate'] as Timestamp?)?.toDate();
    final end = (m['endDate'] as Timestamp?)?.toDate();
    final create = (m['createDate'] as Timestamp?)?.toDate();
    final mapped = {
      ...m,
      'startDate': start,
      'endDate': end,
      'createDate': create,
    };
    return Analysis.fromMap(doc.id, mapped);
  }
}