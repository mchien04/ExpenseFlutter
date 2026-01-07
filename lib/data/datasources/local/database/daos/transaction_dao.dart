import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/transactions_table.dart';
import '../tables/categories_table.dart';
import '../tables/wallets_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, Categories, Wallets])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Future<List<TransactionEntry>> getAllTransactions() =>
      select(transactions).get();

  Future<TransactionEntry?> getTransactionById(String id) {
    return (select(transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<TransactionEntry>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<TransactionEntry>> getTransactionsByWallet(String walletId) {
    return (select(transactions)
          ..where((t) => t.walletId.equals(walletId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<TransactionEntry>> getTransactionsByCategory(String categoryId) {
    return (select(transactions)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<TransactionEntry>> getTransactionsByCategoryAndDateRange(
    String categoryId,
    DateTime start,
    DateTime end,
  ) {
    return (select(transactions)
          ..where((t) =>
              t.categoryId.equals(categoryId) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<TransactionEntry>> getPendingTransactions() {
    return (select(transactions)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Stream<List<TransactionEntry>> watchAllTransactions() {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<TransactionEntry>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<TransactionEntry>> watchTransactionsByWallet(String walletId) {
    return (select(transactions)
          ..where((t) => t.walletId.equals(walletId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  Future<bool> updateTransaction(TransactionsCompanion transaction) {
    return update(transactions).replace(
      transaction.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  Future<int> deleteTransaction(String id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteTransactionsByWallet(String walletId) {
    return (delete(transactions)..where((t) => t.walletId.equals(walletId)))
        .go();
  }

  Future<int> deleteTransactionsByCategory(String categoryId) {
    return (delete(transactions)
          ..where((t) => t.categoryId.equals(categoryId)))
        .go();
  }

  Future<double> getTotalByTypeAndDateRange(
    String type,
    DateTime start,
    DateTime end,
  ) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.type.equals(type) &
          transactions.date.isBiggerOrEqualValue(start) &
          transactions.date.isSmallerOrEqualValue(end) &
          transactions.status.equals('completed'));

    final result = await query.getSingle();
    return result.read(transactions.amount.sum()) ?? 0.0;
  }

  Future<double> getTotalByWalletAndType(String walletId, String type) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.walletId.equals(walletId) &
          transactions.type.equals(type) &
          transactions.status.equals('completed'));

    final result = await query.getSingle();
    return result.read(transactions.amount.sum()) ?? 0.0;
  }

  Future<int> updatePendingToCompleted(DateTime beforeDate) {
    return (update(transactions)
          ..where((t) =>
              t.status.equals('pending') &
              t.date.isSmallerOrEqualValue(beforeDate)))
        .write(
      TransactionsCompanion(
        status: const Value('completed'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
