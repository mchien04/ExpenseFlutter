import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/recurring_template_entity.dart';

class RecurringTemplateValidator {
  static Either<ValidationFailure, RecurringTemplateEntity> validate(
    RecurringTemplateEntity template,
  ) {
    if (template.amount <= 0) {
      return const Left(
        ValidationFailure('Số tiền phải lớn hơn 0'),
      );
    }

    if (template.categoryId.isEmpty) {
      return const Left(
        ValidationFailure('Danh mục không được để trống'),
      );
    }

    if (template.walletId.isEmpty) {
      return const Left(
        ValidationFailure('Ví không được để trống'),
      );
    }

    return Right(template);
  }
}
