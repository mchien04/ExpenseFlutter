import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/utils/date_utils.dart';
import '../entities/transaction_entity.dart';
import '../../core/enums/enums.dart';

class TransactionValidator {
  static Either<ValidationFailure, TransactionEntity> validate(
    TransactionEntity transaction,
  ) {
    if (transaction.amount <= 0) {
      return const Left(
        ValidationFailure('Số tiền phải lớn hơn 0'),
      );
    }

    if (transaction.categoryId.isEmpty) {
      return const Left(
        ValidationFailure('Danh mục không được để trống'),
      );
    }

    if (transaction.walletId.isEmpty) {
      return const Left(
        ValidationFailure('Ví không được để trống'),
      );
    }

    // Auto-set status based on date
    final updatedTransaction = _autoSetStatus(transaction);

    return Right(updatedTransaction);
  }

  static TransactionEntity _autoSetStatus(TransactionEntity transaction) {
    if (AppDateUtils.isFutureDate(transaction.date)) {
      return transaction.copyWith(status: TransactionStatus.pending);
    }
    return transaction.copyWith(status: TransactionStatus.completed);
  }

  static Either<ValidationFailure, double> validateAmount(double amount) {
    if (amount <= 0) {
      return const Left(
        ValidationFailure('Số tiền phải lớn hơn 0'),
      );
    }
    return Right(amount);
  }
}
