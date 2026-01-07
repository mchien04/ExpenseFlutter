import 'package:drift/drift.dart';

import '../../domain/entities/wallet_entity.dart';
import '../datasources/local/database/app_database.dart';

class WalletMapper {
  static WalletEntity fromDriftRow(Wallet row) {
    return WalletEntity(
      id: row.id,
      name: row.name,
      initialBalance: row.initialBalance,
      allowNegativeBalance: row.allowNegativeBalance,
      currencyCode: row.currencyCode,
      isDeleted: row.isDeleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static WalletsCompanion toCompanion(WalletEntity entity) {
    return WalletsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      initialBalance: Value(entity.initialBalance),
      allowNegativeBalance: Value(entity.allowNegativeBalance),
      currencyCode: Value(entity.currencyCode),
      isDeleted: Value(entity.isDeleted),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  static List<WalletEntity> fromDriftRowList(List<Wallet> rows) {
    return rows.map(fromDriftRow).toList();
  }
}
