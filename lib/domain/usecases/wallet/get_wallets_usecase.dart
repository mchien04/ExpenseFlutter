import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/wallet_entity.dart';
import '../../repositories/wallet_repository.dart';

class GetWalletsUseCase {
  final WalletRepository repository;

  GetWalletsUseCase(this.repository);

  Future<Either<Failure, List<WalletEntity>>> call() {
    return repository.getActiveWallets();
  }

  Future<Either<Failure, WalletEntity?>> byId(String id) {
    return repository.getWalletById(id);
  }

  Stream<Either<Failure, List<WalletEntity>>> watch() {
    return repository.watchActiveWallets();
  }

  Future<Either<Failure, double>> getBalance(String walletId) {
    return repository.getWalletBalance(walletId);
  }
}
