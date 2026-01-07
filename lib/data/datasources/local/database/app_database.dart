import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/app_constants.dart';
import 'tables/tables.dart';
import 'daos/category_dao.dart';
import 'daos/wallet_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/budget_dao.dart';
import 'daos/recurring_template_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Wallets,
    Transactions,
    Budgets,
    RecurringTemplates,
  ],
  daos: [
    CategoryDao,
    WalletDao,
    TransactionDao,
    BudgetDao,
    RecurringTemplateDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _seedDefaultData() async {
    // Seed default expense categories
    final expenseCategories = [
      CategoriesCompanion.insert(
        id: 'cat_food',
        name: 'Ăn uống',
        type: 'expense',
        iconCodePoint: 0xe532,
        colorHex: 'FF5722',
      ),
      CategoriesCompanion.insert(
        id: 'cat_transport',
        name: 'Di chuyển',
        type: 'expense',
        iconCodePoint: 0xe531,
        colorHex: '2196F3',
      ),
      CategoriesCompanion.insert(
        id: 'cat_shopping',
        name: 'Mua sắm',
        type: 'expense',
        iconCodePoint: 0xe59c,
        colorHex: '9C27B0',
      ),
      CategoriesCompanion.insert(
        id: 'cat_entertainment',
        name: 'Giải trí',
        type: 'expense',
        iconCodePoint: 0xe40f,
        colorHex: 'E91E63',
      ),
      CategoriesCompanion.insert(
        id: 'cat_health',
        name: 'Sức khỏe',
        type: 'expense',
        iconCodePoint: 0xe3f3,
        colorHex: '4CAF50',
      ),
      CategoriesCompanion.insert(
        id: 'cat_education',
        name: 'Giáo dục',
        type: 'expense',
        iconCodePoint: 0xe80c,
        colorHex: '3F51B5',
      ),
      CategoriesCompanion.insert(
        id: 'cat_bills',
        name: 'Hóa đơn',
        type: 'expense',
        iconCodePoint: 0xe8a0,
        colorHex: '795548',
      ),
      CategoriesCompanion.insert(
        id: 'cat_other_expense',
        name: 'Khác',
        type: 'expense',
        iconCodePoint: 0xe8fe,
        colorHex: '607D8B',
      ),
    ];

    // Seed default income categories
    final incomeCategories = [
      CategoriesCompanion.insert(
        id: 'cat_salary',
        name: 'Lương',
        type: 'income',
        iconCodePoint: 0xe850,
        colorHex: '4CAF50',
      ),
      CategoriesCompanion.insert(
        id: 'cat_bonus',
        name: 'Thưởng',
        type: 'income',
        iconCodePoint: 0xe8f6,
        colorHex: 'FFC107',
      ),
      CategoriesCompanion.insert(
        id: 'cat_investment',
        name: 'Đầu tư',
        type: 'income',
        iconCodePoint: 0xe8e5,
        colorHex: '00BCD4',
      ),
      CategoriesCompanion.insert(
        id: 'cat_gift',
        name: 'Quà tặng',
        type: 'income',
        iconCodePoint: 0xe8f6,
        colorHex: 'FF9800',
      ),
      CategoriesCompanion.insert(
        id: 'cat_other_income',
        name: 'Khác',
        type: 'income',
        iconCodePoint: 0xe8fe,
        colorHex: '9E9E9E',
      ),
    ];

    for (final category in [...expenseCategories, ...incomeCategories]) {
      await into(categories).insert(category);
    }

    // Seed default wallet
    await into(wallets).insert(
      WalletsCompanion.insert(
        id: 'wallet_cash',
        name: 'Tiền mặt',
        initialBalance: const Value(0),
        currencyCode: const Value('VND'),
      ),
    );
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(transactions).go();
      await delete(budgets).go();
      await delete(recurringTemplates).go();
      await delete(wallets).go();
      await delete(categories).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
