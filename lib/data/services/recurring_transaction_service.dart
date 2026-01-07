import 'package:uuid/uuid.dart';

import '../../core/enums/enums.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/recurring_template_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../datasources/local/database/app_database.dart';
import '../mappers/transaction_mapper.dart';

class RecurringTransactionService {
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  RecurringTransactionService(this._database);

  Future<List<TransactionEntity>> processRecurringTemplates() async {
    final now = DateTime.now();
    final today = AppDateUtils.startOfDay(now);

    // Get all templates due for execution
    final templates =
        await _database.recurringTemplateDao.getTemplatesDueForExecution(today);

    final createdTransactions = <TransactionEntity>[];

    for (final template in templates) {
      // Create transaction from template
      final transaction = _createTransactionFromTemplate(template);

      // Insert transaction
      await _database.transactionDao
          .insertTransaction(TransactionMapper.toCompanion(transaction));

      createdTransactions.add(transaction);

      // Calculate next execution date
      final nextDate = _calculateNextExecutionDate(
        template.nextExecutionDate,
        RecurringFrequency.fromString(template.frequency),
      );

      // Update template with next execution date
      await _database.recurringTemplateDao
          .updateNextExecutionDate(template.id, nextDate);
    }

    return createdTransactions;
  }

  TransactionEntity _createTransactionFromTemplate(dynamic template) {
    final now = DateTime.now();
    final transactionDate = template.nextExecutionDate as DateTime;

    // Determine status based on date
    final status = AppDateUtils.isFutureDate(transactionDate)
        ? TransactionStatus.pending
        : TransactionStatus.completed;

    return TransactionEntity(
      id: _uuid.v4(),
      amount: template.amount as double,
      type: TransactionType.fromString(template.type as String),
      categoryId: template.categoryId as String,
      walletId: template.walletId as String,
      date: transactionDate,
      status: status,
      note: '${template.note} (Tự động tạo từ giao dịch định kỳ)',
      createdAt: now,
      updatedAt: now,
    );
  }

  DateTime _calculateNextExecutionDate(
    DateTime currentDate,
    RecurringFrequency frequency,
  ) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return currentDate.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return currentDate.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
    }
  }

  Future<int> updatePendingTransactionsStatus() async {
    final now = DateTime.now();
    final today = AppDateUtils.startOfDay(now);

    return await _database.transactionDao.updatePendingToCompleted(today);
  }

  Future<List<RecurringTemplateEntity>> getUpcomingRecurringTransactions({
    int days = 7,
  }) async {
    final endDate = DateTime.now().add(Duration(days: days));
    final templates =
        await _database.recurringTemplateDao.getTemplatesDueForExecution(endDate);

    return templates
        .map((t) => RecurringTemplateEntity(
              id: t.id,
              amount: t.amount,
              type: TransactionType.fromString(t.type),
              categoryId: t.categoryId,
              walletId: t.walletId,
              frequency: RecurringFrequency.fromString(t.frequency),
              nextExecutionDate: t.nextExecutionDate,
              isActive: t.isActive,
              note: t.note,
              createdAt: t.createdAt,
              updatedAt: t.updatedAt,
            ))
        .toList();
  }
}
