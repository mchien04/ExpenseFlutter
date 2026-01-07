import 'package:drift/drift.dart';

import 'connection_stub.dart'
    if (dart.library.html) 'connection_web.dart'
    if (dart.library.io) 'connection_native.dart';

QueryExecutor openConnection({required String name}) {
  return openConnectionImpl(name: name);
}
