import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, List<WalletEntity>>> getAllWallets();
  Future<Either<Failure, List<WalletEntity>>> getActiveWallets();
  Future<Either<Failure, WalletEntity?>> getWalletById(String id);
  Stream<Either<Failure, List<WalletEntity>>> watchActiveWallets();
  Future<Either<Failure, void>> insertWallet(WalletEntity wallet);
  Future<Either<Failure, void>> updateWallet(WalletEntity wallet);
  Future<Either<Failure, void>> softDeleteWallet(String id);
  Future<Either<Failure, void>> restoreWallet(String id);
  Future<Either<Failure, bool>> walletExists(String id);
  Future<Either<Failure, double>> getWalletBalance(String walletId);
}
