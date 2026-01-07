import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/recurring_templates_table.dart';
import '../tables/categories_table.dart';
import '../tables/wallets_table.dart';

part 'recurring_template_dao.g.dart';

@DriftAccessor(tables: [RecurringTemplates, Categories, Wallets])
class RecurringTemplateDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringTemplateDaoMixin {
  RecurringTemplateDao(super.db);

  Future<List<RecurringTemplate>> getAllTemplates() =>
      select(recurringTemplates).get();

  Future<List<RecurringTemplate>> getActiveTemplates() {
    return (select(recurringTemplates)
          ..where((r) => r.isActive.equals(true)))
        .get();
  }

  Future<RecurringTemplate?> getTemplateById(String id) {
    return (select(recurringTemplates)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<RecurringTemplate>> getTemplatesDueForExecution(DateTime date) {
    return (select(recurringTemplates)
          ..where((r) =>
              r.isActive.equals(true) &
              r.nextExecutionDate.isSmallerOrEqualValue(date)))
        .get();
  }

  Stream<List<RecurringTemplate>> watchAllTemplates() =>
      select(recurringTemplates).watch();

  Stream<List<RecurringTemplate>> watchActiveTemplates() {
    return (select(recurringTemplates)
          ..where((r) => r.isActive.equals(true)))
        .watch();
  }

  Future<int> insertTemplate(RecurringTemplatesCompanion template) {
    return into(recurringTemplates).insert(template);
  }

  Future<bool> updateTemplate(RecurringTemplatesCompanion template) {
    return update(recurringTemplates).replace(
      template.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  Future<int> updateNextExecutionDate(String id, DateTime nextDate) {
    return (update(recurringTemplates)..where((r) => r.id.equals(id))).write(
      RecurringTemplatesCompanion(
        nextExecutionDate: Value(nextDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deactivateTemplate(String id) {
    return (update(recurringTemplates)..where((r) => r.id.equals(id))).write(
      RecurringTemplatesCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> activateTemplate(String id) {
    return (update(recurringTemplates)..where((r) => r.id.equals(id))).write(
      RecurringTemplatesCompanion(
        isActive: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteTemplate(String id) {
    return (delete(recurringTemplates)..where((r) => r.id.equals(id))).go();
  }
}
