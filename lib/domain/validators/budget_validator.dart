import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/budget_entity.dart';

class BudgetValidator {
  static Either<ValidationFailure, BudgetEntity> validate(
    BudgetEntity budget,
  ) {
    if (budget.limitAmount <= 0) {
      return const Left(
        ValidationFailure('Hạn mức phải lớn hơn 0'),
      );
    }

    if (budget.categoryId.isEmpty) {
      return const Left(
        ValidationFailure('Danh mục không được để trống'),
      );
    }

    return Right(budget);
  }

  static Either<ValidationFailure, double> validateLimitAmount(double amount) {
    if (amount <= 0) {
      return const Left(
        ValidationFailure('Hạn mức phải lớn hơn 0'),
      );
    }
    return Right(amount);
  }

  static double calculateUsagePercentage(double spent, double limit) {
    if (limit <= 0) return 0;
    return (spent / limit) * 100;
  }

  static bool isOverBudget(double spent, double limit) {
    return spent > limit;
  }

  static bool isNearLimit(double spent, double limit, {double threshold = 80}) {
    final percentage = calculateUsagePercentage(spent, limit);
    return percentage >= threshold && percentage < 100;
  }
}
