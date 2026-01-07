import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/wallet_repository.dart';
import '../../validators/transaction_validator.dart';

class UpdateTransactionUseCase {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;
  final WalletRepository walletRepository;

  UpdateTransactionUseCase({
    required this.transactionRepository,
    required this.categoryRepository,
    required this.walletRepository,
  });

  Future<Either<Failure, void>> call(TransactionEntity transaction) async {
    // Verify category exists
    final categoryExists =
        await categoryRepository.categoryExists(transaction.categoryId);
    if (categoryExists.isLeft()) {
      return categoryExists.fold(
        (failure) => Left(failure),
        (_) => const Left(ValidationFailure('Lỗi kiểm tra danh mục')),
      );
    }
    final categoryValid = categoryExists.getOrElse(() => false);
    if (!categoryValid) {
      return const Left(ValidationFailure('Danh mục không tồn tại'));
    }

    // Verify wallet exists
    final walletExists =
        await walletRepository.walletExists(transaction.walletId);
    if (walletExists.isLeft()) {
      return walletExists.fold(
        (failure) => Left(failure),
        (_) => const Left(ValidationFailure('Lỗi kiểm tra ví')),
      );
    }
    final walletValid = walletExists.getOrElse(() => false);
    if (!walletValid) {
      return const Left(ValidationFailure('Ví không tồn tại'));
    }

    final updatedTransaction =
        transaction.copyWith(updatedAt: DateTime.now());

    final validationResult = TransactionValidator.validate(updatedTransaction);
    return validationResult.fold(
      (failure) => Left(failure),
      (validTransaction) =>
          transactionRepository.updateTransaction(validTransaction),
    );
  }
}
