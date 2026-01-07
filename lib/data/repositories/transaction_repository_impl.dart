import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/database/app_database.dart';
import '../mappers/transaction_mapper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _database;

  TransactionRepositoryImpl(this._database);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions() async {
    try {
      final rows = await _database.transactionDao.getAllTransactions();
      return Right(TransactionMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy danh sách giao dịch: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity?>> getTransactionById(
      String id) async {
    try {
      final row = await _database.transactionDao.getTransactionById(id);
      if (row == null) return const Right(null);
      return Right(TransactionMapper.fromDriftRow(row));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy giao dịch: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final rows =
          await _database.transactionDao.getTransactionsByDateRange(start, end);
      return Right(TransactionMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy giao dịch theo ngày: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByWallet(
      String walletId) async {
    try {
      final rows =
          await _database.transactionDao.getTransactionsByWallet(walletId);
      return Right(TransactionMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy giao dịch theo ví: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByCategory(
      String categoryId) async {
    try {
      final rows =
          await _database.transactionDao.getTransactionsByCategory(categoryId);
      return Right(TransactionMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy giao dịch theo danh mục: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>>
      getTransactionsByCategoryAndDateRange(
    String categoryId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final rows = await _database.transactionDao
          .getTransactionsByCategoryAndDateRange(categoryId, start, end);
      return Right(TransactionMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(
          DatabaseFailure('Lỗi lấy giao dịch theo danh mục và ngày: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>>
      getPendingTransactions() async {
    try {
      final rows = await _database.transactionDao.getPendingTransactions();
      return Right(TransactionMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy giao dịch đang chờ: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<TransactionEntity>>> watchAllTransactions() {
    return _database.transactionDao.watchAllTransactions().map((rows) {
      try {
        return Right(TransactionMapper.fromDriftRowList(rows));
      } catch (e) {
        return Left(DatabaseFailure('Lỗi theo dõi giao dịch: $e'));
      }
    });
  }

  @override
  Stream<Either<Failure, List<TransactionEntity>>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _database.transactionDao
        .watchTransactionsByDateRange(start, end)
        .map((rows) {
      try {
        return Right(TransactionMapper.fromDriftRowList(rows));
      } catch (e) {
        return Left(DatabaseFailure('Lỗi theo dõi giao dịch: $e'));
      }
    });
  }

  @override
  Stream<Either<Failure, List<TransactionEntity>>> watchTransactionsByWallet(
      String walletId) {
    return _database.transactionDao
        .watchTransactionsByWallet(walletId)
        .map((rows) {
      try {
        return Right(TransactionMapper.fromDriftRowList(rows));
      } catch (e) {
        return Left(DatabaseFailure('Lỗi theo dõi giao dịch: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> insertTransaction(
      TransactionEntity transaction) async {
    try {
      final companion = TransactionMapper.toCompanion(transaction);
      await _database.transactionDao.insertTransaction(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi thêm giao dịch: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
      TransactionEntity transaction) async {
    try {
      final companion = TransactionMapper.toCompanion(transaction);
      await _database.transactionDao.updateTransaction(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi cập nhật giao dịch: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await _database.transactionDao.deleteTransaction(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi xóa giao dịch: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalByTypeAndDateRange(
    String type,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final total = await _database.transactionDao
          .getTotalByTypeAndDateRange(type, start, end);
      return Right(total);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi tính tổng giao dịch: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePendingToCompleted(
      DateTime beforeDate) async {
    try {
      await _database.transactionDao.updatePendingToCompleted(beforeDate);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi cập nhật trạng thái giao dịch: $e'));
    }
  }
}
