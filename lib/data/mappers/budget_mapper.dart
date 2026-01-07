import 'package:drift/drift.dart';

import '../../core/enums/enums.dart';
import '../../domain/entities/budget_entity.dart';
import '../datasources/local/database/app_database.dart';

class BudgetMapper {
  static BudgetEntity fromDriftRow(Budget row) {
    return BudgetEntity(
      id: row.id,
      categoryId: row.categoryId,
      limitAmount: row.limitAmount,
      period: BudgetPeriod.fromString(row.period),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static BudgetsCompanion toCompanion(BudgetEntity entity) {
    return BudgetsCompanion(
      id: Value(entity.id),
      categoryId: Value(entity.categoryId),
      limitAmount: Value(entity.limitAmount),
      period: Value(entity.period.name),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  static List<BudgetEntity> fromDriftRowList(List<Budget> rows) {
    return rows.map(fromDriftRow).toList();
  }
}
