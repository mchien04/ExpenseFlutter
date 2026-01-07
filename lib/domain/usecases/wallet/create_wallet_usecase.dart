import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/failures.dart';
import '../../entities/wallet_entity.dart';
import '../../repositories/wallet_repository.dart';
import '../../validators/wallet_validator.dart';

class CreateWalletUseCase {
  final WalletRepository repository;
  final Uuid _uuid = const Uuid();

  CreateWalletUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String name,
    double initialBalance = 0.0,
    bool allowNegativeBalance = true,
    String currencyCode = 'VND',
  }) async {
    final now = DateTime.now();
    final wallet = WalletEntity(
      id: _uuid.v4(),
      name: name,
      initialBalance: initialBalance,
      allowNegativeBalance: allowNegativeBalance,
      currencyCode: currencyCode,
      createdAt: now,
      updatedAt: now,
    );

    final validationResult = WalletValidator.validate(wallet);
    return validationResult.fold(
      (failure) => Left(failure),
      (validWallet) => repository.insertWallet(validWallet),
    );
  }
}
