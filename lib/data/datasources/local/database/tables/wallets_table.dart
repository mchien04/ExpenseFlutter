import 'package:drift/drift.dart';

class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get initialBalance => real().withDefault(const Constant(0.0))();
  BoolColumn get allowNegativeBalance =>
      boolean().withDefault(const Constant(true))();
  TextColumn get currencyCode =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('VND'))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
