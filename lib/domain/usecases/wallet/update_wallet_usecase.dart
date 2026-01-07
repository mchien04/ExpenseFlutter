import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/wallet_entity.dart';
import '../../repositories/wallet_repository.dart';
import '../../validators/wallet_validator.dart';

class UpdateWalletUseCase {
  final WalletRepository repository;

  UpdateWalletUseCase(this.repository);

  Future<Either<Failure, void>> call(WalletEntity wallet) async {
    final updatedWallet = wallet.copyWith(updatedAt: DateTime.now());

    final validationResult = WalletValidator.validate(updatedWallet);
    return validationResult.fold(
      (failure) => Left(failure),
      (validWallet) => repository.updateWallet(validWallet),
    );
  }
}
