import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/local/database/app_database.dart';
import '../mappers/wallet_mapper.dart';

class WalletRepositoryImpl implements WalletRepository {
  final AppDatabase _database;

  WalletRepositoryImpl(this._database);

  @override
  Future<Either<Failure, List<WalletEntity>>> getAllWallets() async {
    try {
      final rows = await _database.walletDao.getAllWallets();
      return Right(WalletMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy danh sách ví: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WalletEntity>>> getActiveWallets() async {
    try {
      final rows = await _database.walletDao.getActiveWallets();
      return Right(WalletMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy danh sách ví: $e'));
    }
  }

  @override
  Future<Either<Failure, WalletEntity?>> getWalletById(String id) async {
    try {
      final row = await _database.walletDao.getWalletById(id);
      if (row == null) return const Right(null);
      return Right(WalletMapper.fromDriftRow(row));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy ví: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<WalletEntity>>> watchActiveWallets() {
    return _database.walletDao.watchActiveWallets().map((rows) {
      try {
        return Right(WalletMapper.fromDriftRowList(rows));
      } catch (e) {
        return Left(DatabaseFailure('Lỗi theo dõi ví: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> insertWallet(WalletEntity wallet) async {
    try {
      final companion = WalletMapper.toCompanion(wallet);
      await _database.walletDao.insertWallet(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi thêm ví: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateWallet(WalletEntity wallet) async {
    try {
      final companion = WalletMapper.toCompanion(wallet);
      await _database.walletDao.updateWallet(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi cập nhật ví: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> softDeleteWallet(String id) async {
    try {
      await _database.walletDao.softDeleteWallet(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi xóa ví: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> restoreWallet(String id) async {
    try {
      await _database.walletDao.restoreWallet(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi khôi phục ví: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> walletExists(String id) async {
    try {
      final exists = await _database.walletDao.walletExists(id);
      return Right(exists);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi kiểm tra ví: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getWalletBalance(String walletId) async {
    try {
      final wallet = await _database.walletDao.getWalletById(walletId);
      if (wallet == null) {
        return const Left(NotFoundFailure('Ví không tồn tại'));
      }

      final totalIncome = await _database.transactionDao
          .getTotalByWalletAndType(walletId, 'income');
      final totalExpense = await _database.transactionDao
          .getTotalByWalletAndType(walletId, 'expense');

      final balance =
          wallet.initialBalance + totalIncome - totalExpense;
      return Right(balance);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi tính số dư ví: $e'));
    }
  }
}
