import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions();
  Future<Either<Failure, TransactionEntity?>> getTransactionById(String id);
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByWallet(
      String walletId);
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByCategory(
      String categoryId);
  Future<Either<Failure, List<TransactionEntity>>>
      getTransactionsByCategoryAndDateRange(
    String categoryId,
    DateTime start,
    DateTime end,
  );
  Future<Either<Failure, List<TransactionEntity>>> getPendingTransactions();
  Stream<Either<Failure, List<TransactionEntity>>> watchAllTransactions();
  Stream<Either<Failure, List<TransactionEntity>>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );
  Stream<Either<Failure, List<TransactionEntity>>> watchTransactionsByWallet(
      String walletId);
  Future<Either<Failure, void>> insertTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>> updateTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, double>> getTotalByTypeAndDateRange(
    String type,
    DateTime start,
    DateTime end,
  );
  Future<Either<Failure, void>> updatePendingToCompleted(DateTime beforeDate);
}
