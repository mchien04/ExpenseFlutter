import 'package:drift/drift.dart';

import '../../core/enums/enums.dart';
import '../../domain/entities/recurring_template_entity.dart';
import '../datasources/local/database/app_database.dart';

class RecurringTemplateMapper {
  static RecurringTemplateEntity fromDriftRow(RecurringTemplate row) {
    return RecurringTemplateEntity(
      id: row.id,
      amount: row.amount,
      type: TransactionType.fromString(row.type),
      categoryId: row.categoryId,
      walletId: row.walletId,
      frequency: RecurringFrequency.fromString(row.frequency),
      nextExecutionDate: row.nextExecutionDate,
      isActive: row.isActive,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static RecurringTemplatesCompanion toCompanion(
      RecurringTemplateEntity entity) {
    return RecurringTemplatesCompanion(
      id: Value(entity.id),
      amount: Value(entity.amount),
      type: Value(entity.type.name),
      categoryId: Value(entity.categoryId),
      walletId: Value(entity.walletId),
      frequency: Value(entity.frequency.name),
      nextExecutionDate: Value(entity.nextExecutionDate),
      isActive: Value(entity.isActive),
      note: Value(entity.note),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  static List<RecurringTemplateEntity> fromDriftRowList(
      List<RecurringTemplate> rows) {
    return rows.map(fromDriftRow).toList();
  }
}
