import 'package:flutter/material.dart';

import 'package:drift/drift.dart';

class Platform {
  // Connect to the cache database.
  static QueryExecutor createDatabaseConnection(String databaseName) => throw UnsupportedError('');

  // On web cancels the app loading animation. On desktop sets the window parameters (size bounds, transparency, ...).
  static void appReadyHook() => throw UnsupportedError('');

  // On desktop closes the window.
  static void closeWindow() => throw UnsupportedError('');

  // On desktop wraps the widget so that dragging the returned widget moves the window.
  static Widget getWindowMoveWidget() => throw UnsupportedError('');

  // Whether the app is running in the browser or not.
  static bool isWeb() => throw UnsupportedError('');
}
