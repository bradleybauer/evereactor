import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../gui/my_theme.dart';

class Platform {
  static QueryExecutor createDatabaseConnection(String databaseName) {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      // for (var folder in await dbFolder.list().toList()) {
      //   if (folder.uri.pathSegments.isNotEmpty) {
      //     print(folder.uri.pathSegments);
      //   }
      // }
      final file = File(join(dbFolder.path, '$databaseName.sqlite'));
      return NativeDatabase(file);
    });
  }

  static void appReadyHook() async {
    // there is no loader on desktop yet
    WidgetsFlutterBinding.ensureInitialized();
    doWhenWindowReady(() {
      final win = appWindow;
      win.alignment = Alignment.centerRight;
      win.title = "EveIndy";
      // I think + 8 is for the window border
      const sz = Size(MyTheme.appWidth, MyTheme.appHeight + 8);
      win.maxSize = sz;
      win.minSize = sz;
      win.size = sz;
      win.show();
    });

    // await Window.initialize();
    // await Window.setEffect(
    //   effect: WindowEffect.acrylic,
    //   // effect: WindowEffect.tabbed,
    //   // effect: WindowEffect.aero,
    //   color: Colors.white,
    // );
  }

  static void closeWindow() => appWindow.close();

  static Widget getWindowMoveWidget() => MoveWindow();

  static bool isWeb() => false;
}
