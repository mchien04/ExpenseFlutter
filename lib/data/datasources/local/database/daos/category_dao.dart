import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<List<Category>> getAllCategories() => select(categories).get();

  Future<List<Category>> getActiveCategories() {
    return (select(categories)..where((c) => c.isDeleted.equals(false))).get();
  }

  Future<List<Category>> getCategoriesByType(String type) {
    return (select(categories)
          ..where((c) => c.type.equals(type) & c.isDeleted.equals(false)))
        .get();
  }

  Future<Category?> getCategoryById(String id) {
    return (select(categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  Stream<List<Category>> watchActiveCategories() {
    return (select(categories)..where((c) => c.isDeleted.equals(false)))
        .watch();
  }

  Stream<List<Category>> watchCategoriesByType(String type) {
    return (select(categories)
          ..where((c) => c.type.equals(type) & c.isDeleted.equals(false)))
        .watch();
  }

  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  Future<bool> updateCategory(CategoriesCompanion category) {
    return update(categories).replace(
      category.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  Future<int> softDeleteCategory(String id) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> restoreCategory(String id) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<bool> categoryExists(String id) async {
    final category = await getCategoryById(id);
    return category != null && !category.isDeleted;
  }
}
