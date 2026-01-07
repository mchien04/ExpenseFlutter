import 'package:drift/drift.dart';

import 'categories_table.dart';
import 'wallets_table.dart';

class RecurringTemplates extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get frequency => text()();
  DateTimeColumn get nextExecutionDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
