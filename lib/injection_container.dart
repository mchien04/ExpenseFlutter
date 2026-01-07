import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/local/database/app_database.dart';
import 'data/repositories/repositories.dart';
import 'domain/repositories/repositories.dart';
import 'domain/usecases/usecases.dart';

// ============================================================================
// DATABASE
// ============================================================================

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ============================================================================
// REPOSITORIES
// ============================================================================

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(databaseProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(ref.watch(databaseProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(databaseProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(databaseProvider));
});

final recurringTemplateRepositoryProvider =
    Provider<RecurringTemplateRepository>((ref) {
  return RecurringTemplateRepositoryImpl(ref.watch(databaseProvider));
});

// ============================================================================
// CATEGORY USECASES
// ============================================================================

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  return CreateCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  return DeleteCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

// ============================================================================
// WALLET USECASES
// ============================================================================

final getWalletsUseCaseProvider = Provider<GetWalletsUseCase>((ref) {
  return GetWalletsUseCase(ref.watch(walletRepositoryProvider));
});

final createWalletUseCaseProvider = Provider<CreateWalletUseCase>((ref) {
  return CreateWalletUseCase(ref.watch(walletRepositoryProvider));
});

final updateWalletUseCaseProvider = Provider<UpdateWalletUseCase>((ref) {
  return UpdateWalletUseCase(ref.watch(walletRepositoryProvider));
});

final deleteWalletUseCaseProvider = Provider<DeleteWalletUseCase>((ref) {
  return DeleteWalletUseCase(ref.watch(walletRepositoryProvider));
});

// ============================================================================
// TRANSACTION USECASES
// ============================================================================

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  return GetTransactionsUseCase(ref.watch(transactionRepositoryProvider));
});

final createTransactionUseCaseProvider =
    Provider<CreateTransactionUseCase>((ref) {
  return CreateTransactionUseCase(
    transactionRepository: ref.watch(transactionRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    walletRepository: ref.watch(walletRepositoryProvider),
  );
});

final updateTransactionUseCaseProvider =
    Provider<UpdateTransactionUseCase>((ref) {
  return UpdateTransactionUseCase(
    transactionRepository: ref.watch(transactionRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    walletRepository: ref.watch(walletRepositoryProvider),
  );
});

final deleteTransactionUseCaseProvider =
    Provider<DeleteTransactionUseCase>((ref) {
  return DeleteTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

final getTransactionSummaryUseCaseProvider =
    Provider<GetTransactionSummaryUseCase>((ref) {
  return GetTransactionSummaryUseCase(ref.watch(transactionRepositoryProvider));
});

// ============================================================================
// BUDGET USECASES
// ============================================================================

final getBudgetsUseCaseProvider = Provider<GetBudgetsUseCase>((ref) {
  return GetBudgetsUseCase(ref.watch(budgetRepositoryProvider));
});

final createBudgetUseCaseProvider = Provider<CreateBudgetUseCase>((ref) {
  return CreateBudgetUseCase(
    budgetRepository: ref.watch(budgetRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
  );
});

final updateBudgetUseCaseProvider = Provider<UpdateBudgetUseCase>((ref) {
  return UpdateBudgetUseCase(ref.watch(budgetRepositoryProvider));
});

final deleteBudgetUseCaseProvider = Provider<DeleteBudgetUseCase>((ref) {
  return DeleteBudgetUseCase(ref.watch(budgetRepositoryProvider));
});

final checkBudgetStatusUseCaseProvider =
    Provider<CheckBudgetStatusUseCase>((ref) {
  return CheckBudgetStatusUseCase(
    budgetRepository: ref.watch(budgetRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
  );
});

// ============================================================================
// RECURRING TEMPLATE USECASES
// ============================================================================

final getRecurringTemplatesUseCaseProvider =
    Provider<GetRecurringTemplatesUseCase>((ref) {
  return GetRecurringTemplatesUseCase(
      ref.watch(recurringTemplateRepositoryProvider));
});

final createRecurringTemplateUseCaseProvider =
    Provider<CreateRecurringTemplateUseCase>((ref) {
  return CreateRecurringTemplateUseCase(
    templateRepository: ref.watch(recurringTemplateRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    walletRepository: ref.watch(walletRepositoryProvider),
  );
});

final updateRecurringTemplateUseCaseProvider =
    Provider<UpdateRecurringTemplateUseCase>((ref) {
  return UpdateRecurringTemplateUseCase(
      ref.watch(recurringTemplateRepositoryProvider));
});

final deleteRecurringTemplateUseCaseProvider =
    Provider<DeleteRecurringTemplateUseCase>((ref) {
  return DeleteRecurringTemplateUseCase(
      ref.watch(recurringTemplateRepositoryProvider));
});
