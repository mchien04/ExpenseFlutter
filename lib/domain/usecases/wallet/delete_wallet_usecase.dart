import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../repositories/wallet_repository.dart';

class DeleteWalletUseCase {
  final WalletRepository repository;

  DeleteWalletUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.softDeleteWallet(id);
  }

  Future<Either<Failure, void>> restore(String id) {
    return repository.restoreWallet(id);
  }
}
