import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor openConnectionImpl({required String name}) {
  return driftDatabase(name: name);
}
