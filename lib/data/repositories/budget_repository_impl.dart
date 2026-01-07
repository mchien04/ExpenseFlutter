import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/local/database/app_database.dart';
import '../mappers/budget_mapper.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final AppDatabase _database;

  BudgetRepositoryImpl(this._database);

  @override
  Future<Either<Failure, List<BudgetEntity>>> getAllBudgets() async {
    try {
      final rows = await _database.budgetDao.getAllBudgets();
      return Right(BudgetMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy danh sách ngân sách: $e'));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity?>> getBudgetById(String id) async {
    try {
      final row = await _database.budgetDao.getBudgetById(id);
      if (row == null) return const Right(null);
      return Right(BudgetMapper.fromDriftRow(row));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy ngân sách: $e'));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity?>> getBudgetByCategory(
      String categoryId) async {
    try {
      final row = await _database.budgetDao.getBudgetByCategory(categoryId);
      if (row == null) return const Right(null);
      return Right(BudgetMapper.fromDriftRow(row));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy ngân sách theo danh mục: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<BudgetEntity>>> watchAllBudgets() {
    return _database.budgetDao.watchAllBudgets().map((rows) {
      try {
        return Right(BudgetMapper.fromDriftRowList(rows));
      } catch (e) {
        return Left(DatabaseFailure('Lỗi theo dõi ngân sách: $e'));
      }
    });
  }

  @override
  Stream<Either<Failure, BudgetEntity?>> watchBudgetByCategory(
      String categoryId) {
    return _database.budgetDao.watchBudgetByCategory(categoryId).map((row) {
      try {
        if (row == null) return const Right(null);
        return Right(BudgetMapper.fromDriftRow(row));
      } catch (e) {
        return Left(DatabaseFailure('Lỗi theo dõi ngân sách: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> insertBudget(BudgetEntity budget) async {
    try {
      final companion = BudgetMapper.toCompanion(budget);
      await _database.budgetDao.insertBudget(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi thêm ngân sách: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBudget(BudgetEntity budget) async {
    try {
      final companion = BudgetMapper.toCompanion(budget);
      await _database.budgetDao.updateBudget(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi cập nhật ngân sách: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      await _database.budgetDao.deleteBudget(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi xóa ngân sách: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> budgetExistsForCategory(
      String categoryId) async {
    try {
      final exists =
          await _database.budgetDao.budgetExistsForCategory(categoryId);
      return Right(exists);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi kiểm tra ngân sách: $e'));
    }
  }
}
