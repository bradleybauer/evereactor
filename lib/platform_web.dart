// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:sqlite3/wasm.dart';

import 'controllers/build_items.dart';
import 'controllers/inventory.dart';
import 'controllers/options.dart';
import 'controllers/schedule_provider.dart';
import 'controllers/schedule_provider_web.dart';

class Platform {
  static QueryExecutor createDatabaseConnection(String databaseName) {
    return LazyDatabase(() async {
      // Load wasm bundle
      final response = await http.get(Uri.parse('sqlite3.wasm'));
      // Create a virtual file system backed by IndexedDb with everything in
      // `/drift/my_app/` being persisted.
      final fs = await IndexedDbFileSystem.open(dbName: databaseName);
      final sqlite3 = await WasmSqlite3.load(
        response.bodyBytes,
        SqliteEnvironment(fileSystem: fs),
      );

      // Then, open a database inside that persisted folder.
      return WasmDatabase(sqlite3: sqlite3, path: '/drift/evereactor/' + databaseName + '.db');
    });
  }

  static void appReadyHook() {
    querySelector("#loader")?.remove();
  }

  static void closeWindow() {}

  static Widget getWindowMoveWidget() => const SizedBox();

  static bool isWeb() => true;

  static ScheduleProvider getScheduleProvider(InventoryController inv, OptionsController ops, BuildItemsController items) => ScheduleProviderWeb(inventory: inv, options: ops, buildItems: items);

  static Widget getOptimizerPane() => const SizedBox();
}
