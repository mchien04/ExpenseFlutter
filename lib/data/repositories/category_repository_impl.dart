import 'package:dartz/dartz.dart';

import '../../core/enums/enums.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/database/app_database.dart';
import '../mappers/category_mapper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _database;

  CategoryRepositoryImpl(this._database);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    try {
      final rows = await _database.categoryDao.getAllCategories();
      return Right(CategoryMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy danh sách danh mục: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getActiveCategories() async {
    try {
      final rows = await _database.categoryDao.getActiveCategories();
      return Right(CategoryMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy danh sách danh mục: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategoriesByType(
      TransactionType type) async {
    try {
      final rows = await _database.categoryDao.getCategoriesByType(type.name);
      return Right(CategoryMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy danh mục theo loại: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity?>> getCategoryById(String id) async {
    try {
      final row = await _database.categoryDao.getCategoryById(id);
      if (row == null) return const Right(null);
      return Right(CategoryMapper.fromDriftRow(row));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy danh mục: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<CategoryEntity>>> watchActiveCategories() {
    return _database.categoryDao.watchActiveCategories().map((rows) {
      try {
        return Right(CategoryMapper.fromDriftRowList(rows));
      } catch (e) {
        return Left(DatabaseFailure('Lỗi theo dõi danh mục: $e'));
      }
    });
  }

  @override
  Stream<Either<Failure, List<CategoryEntity>>> watchCategoriesByType(
      TransactionType type) {
    return _database.categoryDao.watchCategoriesByType(type.name).map((rows) {
      try {
        return Right(CategoryMapper.fromDriftRowList(rows));
      } catch (e) {
        return Left(DatabaseFailure('Lỗi theo dõi danh mục: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> insertCategory(CategoryEntity category) async {
    try {
      final companion = CategoryMapper.toCompanion(category);
      await _database.categoryDao.insertCategory(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi thêm danh mục: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(CategoryEntity category) async {
    try {
      final companion = CategoryMapper.toCompanion(category);
      await _database.categoryDao.updateCategory(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi cập nhật danh mục: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> softDeleteCategory(String id) async {
    try {
      await _database.categoryDao.softDeleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi xóa danh mục: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> restoreCategory(String id) async {
    try {
      await _database.categoryDao.restoreCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi khôi phục danh mục: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> categoryExists(String id) async {
    try {
      final exists = await _database.categoryDao.categoryExists(id);
      return Right(exists);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi kiểm tra danh mục: $e'));
    }
  }
}
