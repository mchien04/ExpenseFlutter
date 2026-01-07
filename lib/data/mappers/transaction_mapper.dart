import 'package:drift/drift.dart';

import '../../core/enums/enums.dart';
import '../../domain/entities/transaction_entity.dart';
import '../datasources/local/database/app_database.dart';

class TransactionMapper {
  static TransactionEntity fromDriftRow(TransactionEntry row) {
    return TransactionEntity(
      id: row.id,
      amount: row.amount,
      type: TransactionType.fromString(row.type),
      categoryId: row.categoryId,
      walletId: row.walletId,
      date: row.date,
      status: TransactionStatus.fromString(row.status),
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static TransactionsCompanion toCompanion(TransactionEntity entity) {
    return TransactionsCompanion(
      id: Value(entity.id),
      amount: Value(entity.amount),
      type: Value(entity.type.name),
      categoryId: Value(entity.categoryId),
      walletId: Value(entity.walletId),
      date: Value(entity.date),
      status: Value(entity.status.name),
      note: Value(entity.note),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  static List<TransactionEntity> fromDriftRowList(List<TransactionEntry> rows) {
    return rows.map(fromDriftRow).toList();
  }
}
