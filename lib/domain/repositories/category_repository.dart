import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../../core/enums/enums.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories();
  Future<Either<Failure, List<CategoryEntity>>> getActiveCategories();
  Future<Either<Failure, List<CategoryEntity>>> getCategoriesByType(
      TransactionType type);
  Future<Either<Failure, CategoryEntity?>> getCategoryById(String id);
  Stream<Either<Failure, List<CategoryEntity>>> watchActiveCategories();
  Stream<Either<Failure, List<CategoryEntity>>> watchCategoriesByType(
      TransactionType type);
  Future<Either<Failure, void>> insertCategory(CategoryEntity category);
  Future<Either<Failure, void>> updateCategory(CategoryEntity category);
  Future<Either<Failure, void>> softDeleteCategory(String id);
  Future<Either<Failure, void>> restoreCategory(String id);
  Future<Either<Failure, bool>> categoryExists(String id);
}
