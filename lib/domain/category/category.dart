
class Category {
  final String id; 
  final String categoryId;
  final DateTime createDate;
  final String description;
  final String icon;
  final bool state;
  final String userCreate;

  Category({
    required this.id,
    required this.categoryId,
    required this.createDate,
    required this.description,
    required this.icon,
    required this.state,
    required this.userCreate,
  });

  factory Category.fromMap(String id, Map<String, dynamic> map) {
    return Category(
      id: id,
      categoryId: map['categoryid']?.toString() ?? '',
      createDate: (map['createdate'] is DateTime)
          ? map['createdate']
          : DateTime.tryParse(map['createdate'].toString()) ?? DateTime.now(),
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      state: map['state'] ?? false,
      userCreate: map['usercreate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryid': categoryId,
      'createdate': createDate.toIso8601String(),
      'description': description,
      'icon': icon,
      'state': state,
      'usercreate': userCreate,
    };
  }
}
