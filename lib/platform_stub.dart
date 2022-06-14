import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'controllers/build_items.dart';
import 'controllers/inventory.dart';
import 'controllers/options.dart';
import 'controllers/schedule_provider.dart';

class Platform {
  // Connect to the cache database.
  static Future<QueryExecutor> createDatabaseConnection(String databaseName) => throw Error();

  // On web cancels the app loading animation. On desktop sets the window parameters (size bounds, transparency, ...).
  static void appReadyHook() => throw Error();

  // On desktop closes the window.
  static void closeWindow() => throw Error();

  // On desktop wraps the widget so that dragging the returned widget moves the window.
  static Widget getWindowMoveWidget() => throw Error();

  // Whether the app is running in the browser or not.
  static bool isWeb() => throw Error();

  static ScheduleProvider getScheduleProvider(InventoryController inv, OptionsController ops, BuildItemsController items) => throw Error();

  static Widget getOptimizerPane() => throw Error();
}
