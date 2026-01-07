import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../core/enums/enums.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final TransactionType type;
  final int iconCodePoint;
  final String colorHex;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.colorHex,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Color get color => Color(int.parse('FF$colorHex', radix: 16));

  CategoryEntity copyWith({
    String? id,
    String? name,
    TransactionType? type,
    int? iconCodePoint,
    String? colorHex,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorHex: colorHex ?? this.colorHex,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        iconCodePoint,
        colorHex,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
