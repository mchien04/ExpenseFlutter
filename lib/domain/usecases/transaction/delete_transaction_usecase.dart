import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteTransaction(id);
  }
}
