// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:drift/drift.dart';
import 'package:drift/remote.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Platform {
  // static QueryExecutor createDatabaseConnection(String databaseName) {
  //   return LazyDatabase(() async {
  //     return WebDatabase(databaseName);
  //   });
  // }

  static QueryExecutor createDatabaseConnection(String databaseName) {
    return LazyDatabase(() async {
      return _connectToWorker(databaseName).executor;
    });
  }

  static DatabaseConnection _connectToWorker(String databaseName) {
    final worker = SharedWorker(kReleaseMode ? 'cacheDbWorker.dart.min.js' : 'cacheDbWorker.dart.js', databaseName);
    return remote(worker.port!.channel());
  }

  static void appReadyHook() {
    querySelector("#loader")?.remove();
    // or
    // Future.delayed(const Duration(seconds: 2), () {
    //   // remove loader
    //   querySelector("#loader")?.remove();
    // });
  }

  static void closeWindow() {}

  static Widget getWindowMoveWidget() => const SizedBox();

  static bool isWeb() => true;
}
