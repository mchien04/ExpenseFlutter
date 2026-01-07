import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../data/services/recurring_transaction_service.dart';
import '../../entities/transaction_entity.dart';

class ProcessRecurringUseCase {
  final RecurringTransactionService _service;

  ProcessRecurringUseCase(this._service);

  Future<Either<Failure, List<TransactionEntity>>> call() async {
    try {
      final transactions = await _service.processRecurringTemplates();
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi xử lý giao dịch định kỳ: $e'));
    }
  }

  Future<Either<Failure, int>> updatePendingStatus() async {
    try {
      final count = await _service.updatePendingTransactionsStatus();
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi cập nhật trạng thái giao dịch: $e'));
    }
  }
}
