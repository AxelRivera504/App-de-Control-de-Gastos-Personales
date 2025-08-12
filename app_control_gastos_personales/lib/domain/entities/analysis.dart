
class Analysis {
  final String id;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String userCreate;
  final DateTime? createDate;
  final int? iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;

  Analysis({
    required this.id,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    required this.userCreate,
    this.createDate,
    this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'userCreate': userCreate,
      'createDate': createDate,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'iconFontPackage': iconFontPackage,
    };
  }

  factory Analysis.fromMap(String id, Map<String, dynamic> m) {
    return Analysis(
      id: id,
      title: (m['title'] ?? '').toString(),
      description: (m['description'] ?? '').toString(),
      startDate: m['startDate'] as DateTime?,
      endDate: m['endDate'] as DateTime?,
      userCreate: (m['userCreate'] ?? '').toString(),
      createDate: m['createDate'] as DateTime?,
      iconCodePoint: (m['iconCodePoint'] as num?)?.toInt(),
      iconFontFamily: m['iconFontFamily'] as String?,
      iconFontPackage: m['iconFontPackage'] as String?,
    );
  }
}
