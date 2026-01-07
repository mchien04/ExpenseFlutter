import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnectionImpl({required String name}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final lower = name.toLowerCase();
    final hasExtension = lower.endsWith('.db') ||
        lower.endsWith('.sqlite') ||
        lower.endsWith('.sqlite3');

    final fileName = hasExtension ? name : '$name.sqlite';
    final file = File(p.join(dbFolder.path, fileName));
    return NativeDatabase.createInBackground(file);
  });
}
