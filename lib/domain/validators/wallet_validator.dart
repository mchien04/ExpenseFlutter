import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/wallet_entity.dart';

class WalletValidator {
  static Either<ValidationFailure, WalletEntity> validate(
    WalletEntity wallet,
  ) {
    if (wallet.name.trim().isEmpty) {
      return const Left(
        ValidationFailure('Tên ví không được để trống'),
      );
    }

    if (wallet.name.length > 100) {
      return const Left(
        ValidationFailure('Tên ví không được quá 100 ký tự'),
      );
    }

    if (wallet.currencyCode.length != 3) {
      return const Left(
        ValidationFailure('Mã tiền tệ không hợp lệ'),
      );
    }

    return Right(wallet);
  }

  static Either<ValidationFailure, String> validateName(String name) {
    if (name.trim().isEmpty) {
      return const Left(
        ValidationFailure('Tên ví không được để trống'),
      );
    }

    if (name.length > 100) {
      return const Left(
        ValidationFailure('Tên ví không được quá 100 ký tự'),
      );
    }

    return Right(name);
  }

  static bool checkNegativeBalance(
    double currentBalance,
    double transactionAmount,
    bool isExpense,
    bool allowNegativeBalance,
  ) {
    if (!allowNegativeBalance && isExpense) {
      final newBalance = currentBalance - transactionAmount;
      return newBalance < 0;
    }
    return false;
  }
}
