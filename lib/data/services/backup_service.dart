import 'dart:convert';

import '../../core/enums/enums.dart';
import '../../domain/entities/entities.dart';
import '../datasources/local/database/app_database.dart';
import '../mappers/mappers.dart';

class BackupData {
  final List<CategoryEntity> categories;
  final List<WalletEntity> wallets;
  final List<TransactionEntity> transactions;
  final List<BudgetEntity> budgets;
  final List<RecurringTemplateEntity> recurringTemplates;
  final DateTime exportedAt;
  final String version;

  BackupData({
    required this.categories,
    required this.wallets,
    required this.transactions,
    required this.budgets,
    required this.recurringTemplates,
    required this.exportedAt,
    this.version = '1.0.0',
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'exportedAt': exportedAt.toIso8601String(),
      'categories': categories.map((c) => _categoryToJson(c)).toList(),
      'wallets': wallets.map((w) => _walletToJson(w)).toList(),
      'transactions': transactions.map((t) => _transactionToJson(t)).toList(),
      'budgets': budgets.map((b) => _budgetToJson(b)).toList(),
      'recurringTemplates':
          recurringTemplates.map((r) => _recurringToJson(r)).toList(),
    };
  }

  static BackupData fromJson(Map<String, dynamic> json) {
    return BackupData(
      version: json['version'] ?? '1.0.0',
      exportedAt: DateTime.parse(json['exportedAt']),
      categories: (json['categories'] as List)
          .map((c) => _categoryFromJson(c))
          .toList(),
      wallets:
          (json['wallets'] as List).map((w) => _walletFromJson(w)).toList(),
      transactions: (json['transactions'] as List)
          .map((t) => _transactionFromJson(t))
          .toList(),
      budgets:
          (json['budgets'] as List).map((b) => _budgetFromJson(b)).toList(),
      recurringTemplates: (json['recurringTemplates'] as List)
          .map((r) => _recurringFromJson(r))
          .toList(),
    );
  }

  static Map<String, dynamic> _categoryToJson(CategoryEntity c) => {
        'id': c.id,
        'name': c.name,
        'type': c.type.name,
        'iconCodePoint': c.iconCodePoint,
        'colorHex': c.colorHex,
        'isDeleted': c.isDeleted,
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt.toIso8601String(),
      };

  static CategoryEntity _categoryFromJson(Map<String, dynamic> json) =>
      CategoryEntity(
        id: json['id'],
        name: json['name'],
        type: TransactionType.fromString(json['type']),
        iconCodePoint: json['iconCodePoint'],
        colorHex: json['colorHex'],
        isDeleted: json['isDeleted'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  static Map<String, dynamic> _walletToJson(WalletEntity w) => {
        'id': w.id,
        'name': w.name,
        'initialBalance': w.initialBalance,
        'allowNegativeBalance': w.allowNegativeBalance,
        'currencyCode': w.currencyCode,
        'isDeleted': w.isDeleted,
        'createdAt': w.createdAt.toIso8601String(),
        'updatedAt': w.updatedAt.toIso8601String(),
      };

  static WalletEntity _walletFromJson(Map<String, dynamic> json) =>
      WalletEntity(
        id: json['id'],
        name: json['name'],
        initialBalance: (json['initialBalance'] as num).toDouble(),
        allowNegativeBalance: json['allowNegativeBalance'] ?? true,
        currencyCode: json['currencyCode'] ?? 'VND',
        isDeleted: json['isDeleted'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  static Map<String, dynamic> _transactionToJson(TransactionEntity t) => {
        'id': t.id,
        'amount': t.amount,
        'type': t.type.name,
        'categoryId': t.categoryId,
        'walletId': t.walletId,
        'date': t.date.toIso8601String(),
        'status': t.status.name,
        'note': t.note,
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
      };

  static TransactionEntity _transactionFromJson(Map<String, dynamic> json) =>
      TransactionEntity(
        id: json['id'],
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.fromString(json['type']),
        categoryId: json['categoryId'],
        walletId: json['walletId'],
        date: DateTime.parse(json['date']),
        status: TransactionStatus.fromString(json['status']),
        note: json['note'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  static Map<String, dynamic> _budgetToJson(BudgetEntity b) => {
        'id': b.id,
        'categoryId': b.categoryId,
        'limitAmount': b.limitAmount,
        'period': b.period.name,
        'createdAt': b.createdAt.toIso8601String(),
        'updatedAt': b.updatedAt.toIso8601String(),
      };

  static BudgetEntity _budgetFromJson(Map<String, dynamic> json) =>
      BudgetEntity(
        id: json['id'],
        categoryId: json['categoryId'],
        limitAmount: (json['limitAmount'] as num).toDouble(),
        period: BudgetPeriod.fromString(json['period']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  static Map<String, dynamic> _recurringToJson(RecurringTemplateEntity r) => {
        'id': r.id,
        'amount': r.amount,
        'type': r.type.name,
        'categoryId': r.categoryId,
        'walletId': r.walletId,
        'frequency': r.frequency.name,
        'nextExecutionDate': r.nextExecutionDate.toIso8601String(),
        'isActive': r.isActive,
        'note': r.note,
        'createdAt': r.createdAt.toIso8601String(),
        'updatedAt': r.updatedAt.toIso8601String(),
      };

  static RecurringTemplateEntity _recurringFromJson(Map<String, dynamic> json) =>
      RecurringTemplateEntity(
        id: json['id'],
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.fromString(json['type']),
        categoryId: json['categoryId'],
        walletId: json['walletId'],
        frequency: RecurringFrequency.fromString(json['frequency']),
        nextExecutionDate: DateTime.parse(json['nextExecutionDate']),
        isActive: json['isActive'] ?? true,
        note: json['note'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}

class BackupService {
  final AppDatabase _database;

  BackupService(this._database);

  Future<String> exportToJson() async {
    final categories = await _database.categoryDao.getAllCategories();
    final wallets = await _database.walletDao.getAllWallets();
    final transactions = await _database.transactionDao.getAllTransactions();
    final budgets = await _database.budgetDao.getAllBudgets();
    final recurringTemplates =
        await _database.recurringTemplateDao.getAllTemplates();

    final backupData = BackupData(
      categories: CategoryMapper.fromDriftRowList(categories),
      wallets: WalletMapper.fromDriftRowList(wallets),
      transactions: TransactionMapper.fromDriftRowList(transactions),
      budgets: BudgetMapper.fromDriftRowList(budgets),
      recurringTemplates:
          RecurringTemplateMapper.fromDriftRowList(recurringTemplates),
      exportedAt: DateTime.now(),
    );

    return const JsonEncoder.withIndent('  ').convert(backupData.toJson());
  }

  Future<String> exportToCsv() async {
    final transactions = await _database.transactionDao.getAllTransactions();
    final categories = await _database.categoryDao.getAllCategories();
    final wallets = await _database.walletDao.getAllWallets();

    final categoryMap = {for (var c in categories) c.id: c.name};
    final walletMap = {for (var w in wallets) w.id: w.name};

    final buffer = StringBuffer();
    buffer.writeln(
        'ID,Date,Type,Amount,Category,Wallet,Status,Note,CreatedAt,UpdatedAt');

    for (final t in transactions) {
      final categoryName = categoryMap[t.categoryId] ?? 'Unknown';
      final walletName = walletMap[t.walletId] ?? 'Unknown';
      final note = t.note.replaceAll('"', '""');

      buffer.writeln(
        '${t.id},'
        '${t.date.toIso8601String()},'
        '${t.type},'
        '${t.amount},'
        '"$categoryName",'
        '"$walletName",'
        '${t.status},'
        '"$note",'
        '${t.createdAt.toIso8601String()},'
        '${t.updatedAt.toIso8601String()}',
      );
    }

    return buffer.toString();
  }

  Future<void> importFromJson(String jsonData) async {
    final json = jsonDecode(jsonData) as Map<String, dynamic>;
    final backupData = BackupData.fromJson(json);

    await _database.transaction(() async {
      // Clear existing data
      await _database.clearAllData();

      // Import categories first (referenced by other tables)
      for (final category in backupData.categories) {
        await _database.categoryDao
            .insertCategory(CategoryMapper.toCompanion(category));
      }

      // Import wallets (referenced by transactions)
      for (final wallet in backupData.wallets) {
        await _database.walletDao
            .insertWallet(WalletMapper.toCompanion(wallet));
      }

      // Import transactions
      for (final transaction in backupData.transactions) {
        await _database.transactionDao
            .insertTransaction(TransactionMapper.toCompanion(transaction));
      }

      // Import budgets
      for (final budget in backupData.budgets) {
        await _database.budgetDao
            .insertBudget(BudgetMapper.toCompanion(budget));
      }

      // Import recurring templates
      for (final template in backupData.recurringTemplates) {
        await _database.recurringTemplateDao
            .insertTemplate(RecurringTemplateMapper.toCompanion(template));
      }
    });
  }

  Future<void> clearAllData() async {
    await _database.clearAllData();
  }
}
