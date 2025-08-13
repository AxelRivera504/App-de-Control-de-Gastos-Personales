import 'package:flutter/material.dart';


class Category {
  final String id;
  final String description;
  final bool state;
  final String userCreate;
  final DateTime? createDate;

  final int iconCodePoint;
  final String iconFontFamily;
  final String? iconFontPackage;

  final int defaultTypeId;

  const Category({
    required this.id,
    required this.description,
    required this.state,
    required this.userCreate,
    required this.createDate,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.iconFontPackage,
    required this.defaultTypeId,
  });

  IconData get iconData => IconData(
        iconCodePoint,
        fontFamily: iconFontFamily,
        fontPackage: iconFontPackage,
      );

  Category copyWith({
    String? id,
    String? description,
    bool? state,
    String? userCreate,
    DateTime? createDate,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    int? defaultTypeId,
  }) =>
      Category(
        id: id ?? this.id,
        description: description ?? this.description,
        state: state ?? this.state,
        userCreate: userCreate ?? this.userCreate,
        createDate: createDate ?? this.createDate,
        iconCodePoint: iconCodePoint ?? this.iconCodePoint,
        iconFontFamily: iconFontFamily ?? this.iconFontFamily,
        iconFontPackage: iconFontPackage ?? this.iconFontPackage,
        defaultTypeId: defaultTypeId ?? this.defaultTypeId,
      );
}