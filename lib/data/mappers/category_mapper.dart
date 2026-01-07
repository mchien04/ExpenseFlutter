import 'package:drift/drift.dart';

import '../../core/enums/enums.dart';
import '../../domain/entities/category_entity.dart';
import '../datasources/local/database/app_database.dart';

class CategoryMapper {
  static CategoryEntity fromDriftRow(Category row) {
    return CategoryEntity(
      id: row.id,
      name: row.name,
      type: TransactionType.fromString(row.type),
      iconCodePoint: row.iconCodePoint,
      colorHex: row.colorHex,
      isDeleted: row.isDeleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static CategoriesCompanion toCompanion(CategoryEntity entity) {
    return CategoriesCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      type: Value(entity.type.name),
      iconCodePoint: Value(entity.iconCodePoint),
      colorHex: Value(entity.colorHex),
      isDeleted: Value(entity.isDeleted),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  static List<CategoryEntity> fromDriftRowList(List<Category> rows) {
    return rows.map(fromDriftRow).toList();
  }
}
