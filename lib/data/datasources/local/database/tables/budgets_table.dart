import 'package:drift/drift.dart';

import 'categories_table.dart';

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  RealColumn get limitAmount => real()();
  TextColumn get period => text().withDefault(const Constant('monthly'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
