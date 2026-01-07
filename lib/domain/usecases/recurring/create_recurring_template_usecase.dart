import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/failures.dart';
import '../../../core/enums/enums.dart';
import '../../entities/recurring_template_entity.dart';
import '../../repositories/recurring_template_repository.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/wallet_repository.dart';
import '../../validators/recurring_template_validator.dart';

class CreateRecurringTemplateUseCase {
  final RecurringTemplateRepository templateRepository;
  final CategoryRepository categoryRepository;
  final WalletRepository walletRepository;
  final Uuid _uuid = const Uuid();

  CreateRecurringTemplateUseCase({
    required this.templateRepository,
    required this.categoryRepository,
    required this.walletRepository,
  });

  Future<Either<Failure, void>> call({
    required double amount,
    required TransactionType type,
    required String categoryId,
    required String walletId,
    required RecurringFrequency frequency,
    required DateTime nextExecutionDate,
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
    final template = RecurringTemplateEntity(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      categoryId: categoryId,
      walletId: walletId,
      frequency: frequency,
      nextExecutionDate: nextExecutionDate,
      note: note,
      createdAt: now,
      updatedAt: now,
    );

    final validationResult = RecurringTemplateValidator.validate(template);
    return validationResult.fold(
      (failure) => Left(failure),
      (validTemplate) => templateRepository.insertTemplate(validTemplate),
    );
  }
}
