// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:drift/drift.dart';
import 'package:drift/remote.dart';
import 'package:drift/web.dart';

Future<void> main() async {
  print('web worker setup');
  final self = SharedWorkerGlobalScope.instance;
  self.importScripts('sql-wasm.js');

  final db = WebDatabase.withStorage(DriftWebStorage.indexedDb('persistenceWorker', migrateFromLocalStorage: false, inWebWorker: true),
      logStatements: true);
  final server = DriftServer(DatabaseConnection.fromExecutor(db));

  self.onConnect.listen((event) {
    print(' web worker event hai ');
    final msg = event as MessageEvent;
    server.serve(msg.ports.first.channel());
  });
}
