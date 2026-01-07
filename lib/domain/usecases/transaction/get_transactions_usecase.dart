import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call() {
    return repository.getAllTransactions();
  }

  Future<Either<Failure, TransactionEntity?>> byId(String id) {
    return repository.getTransactionById(id);
  }

  Future<Either<Failure, List<TransactionEntity>>> byDateRange(
    DateTime start,
    DateTime end,
  ) {
    return repository.getTransactionsByDateRange(start, end);
  }

  Future<Either<Failure, List<TransactionEntity>>> byWallet(String walletId) {
    return repository.getTransactionsByWallet(walletId);
  }

  Future<Either<Failure, List<TransactionEntity>>> byCategory(
      String categoryId) {
    return repository.getTransactionsByCategory(categoryId);
  }

  Future<Either<Failure, List<TransactionEntity>>> byCategoryAndDateRange(
    String categoryId,
    DateTime start,
    DateTime end,
  ) {
    return repository.getTransactionsByCategoryAndDateRange(
        categoryId, start, end);
  }

  Future<Either<Failure, List<TransactionEntity>>> pending() {
    return repository.getPendingTransactions();
  }

  Stream<Either<Failure, List<TransactionEntity>>> watch() {
    return repository.watchAllTransactions();
  }

  Stream<Either<Failure, List<TransactionEntity>>> watchByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return repository.watchTransactionsByDateRange(start, end);
  }

  Stream<Either<Failure, List<TransactionEntity>>> watchByWallet(
      String walletId) {
    return repository.watchTransactionsByWallet(walletId);
  }
}
