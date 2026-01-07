import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/failures.dart';
import '../../../core/enums/enums.dart';
import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/wallet_repository.dart';
import '../../validators/transaction_validator.dart';

class CreateTransactionUseCase {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;
  final WalletRepository walletRepository;
  final Uuid _uuid = const Uuid();

  CreateTransactionUseCase({
    required this.transactionRepository,
    required this.categoryRepository,
    required this.walletRepository,
  });

  Future<Either<Failure, void>> call({
    required double amount,
    required TransactionType type,
    required String categoryId,
    required String walletId,
    required DateTime date,
    String note = '',
  }) async {
    // Verify category exists
    final categoryExists = await categoryRepository.categoryExists(categoryId);
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
    final walletExists = await walletRepository.walletExists(walletId);
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

    final now = DateTime.now();
    final transaction = TransactionEntity(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      categoryId: categoryId,
      walletId: walletId,
      date: date,
      note: note,
      createdAt: now,
      updatedAt: now,
    );

    final validationResult = TransactionValidator.validate(transaction);
    return validationResult.fold(
      (failure) => Left(failure),
      (validTransaction) =>
          transactionRepository.insertTransaction(validTransaction),
    );
  }
}
