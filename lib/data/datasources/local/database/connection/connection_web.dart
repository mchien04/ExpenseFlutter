import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openConnectionImpl({required String name}) {
  return WebDatabase(name);
}
