import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/budgets_table.dart';
import '../tables/categories_table.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets, Categories])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Future<List<Budget>> getAllBudgets() => select(budgets).get();

  Future<Budget?> getBudgetById(String id) {
    return (select(budgets)..where((b) => b.id.equals(id))).getSingleOrNull();
  }

  Future<Budget?> getBudgetByCategory(String categoryId) {
    return (select(budgets)..where((b) => b.categoryId.equals(categoryId)))
        .getSingleOrNull();
  }

  Stream<List<Budget>> watchAllBudgets() => select(budgets).watch();

  Stream<Budget?> watchBudgetByCategory(String categoryId) {
    return (select(budgets)..where((b) => b.categoryId.equals(categoryId)))
        .watchSingleOrNull();
  }

  Future<int> insertBudget(BudgetsCompanion budget) {
    return into(budgets).insert(budget);
  }

  Future<bool> updateBudget(BudgetsCompanion budget) {
    return update(budgets).replace(
      budget.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  Future<int> deleteBudget(String id) {
    return (delete(budgets)..where((b) => b.id.equals(id))).go();
  }

  Future<int> deleteBudgetByCategory(String categoryId) {
    return (delete(budgets)..where((b) => b.categoryId.equals(categoryId)))
        .go();
  }

  Future<bool> budgetExistsForCategory(String categoryId) async {
    final budget = await getBudgetByCategory(categoryId);
    return budget != null;
  }
}
