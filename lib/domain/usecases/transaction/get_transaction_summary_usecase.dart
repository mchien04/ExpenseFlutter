import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/utils/date_utils.dart';
import '../../repositories/transaction_repository.dart';

class TransactionSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final DateTime startDate;
  final DateTime endDate;

  TransactionSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.startDate,
    required this.endDate,
  }) : balance = totalIncome - totalExpense;
}

class GetTransactionSummaryUseCase {
  final TransactionRepository repository;

  GetTransactionSummaryUseCase(this.repository);

  Future<Either<Failure, TransactionSummary>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = AppDateUtils.startOfDay(startDate);
    final end = AppDateUtils.endOfDay(endDate);

    final incomeResult =
        await repository.getTotalByTypeAndDateRange('income', start, end);
    final expenseResult =
        await repository.getTotalByTypeAndDateRange('expense', start, end);

    return incomeResult.fold(
      (failure) => Left(failure),
      (income) => expenseResult.fold(
        (failure) => Left(failure),
        (expense) => Right(TransactionSummary(
          totalIncome: income,
          totalExpense: expense,
          startDate: start,
          endDate: end,
        )),
      ),
    );
  }

  Future<Either<Failure, TransactionSummary>> forCurrentMonth() {
    final now = DateTime.now();
    return call(
      startDate: AppDateUtils.startOfMonth(now),
      endDate: AppDateUtils.endOfMonth(now),
    );
  }
}
