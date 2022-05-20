import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../gui/my_theme.dart';
import 'controllers/build_items.dart';
import 'controllers/inventory.dart';
import 'controllers/optimizer.dart';
import 'controllers/options.dart';
import 'controllers/schedule_provider.dart';
import 'controllers/schedule_provider_desktop.dart';
import 'gui/widgets/flyout_optimizer.dart';
import 'solver/advanced_solver.dart';

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
      win.title = "My Little Reactor";
      // TODO(desktop) I am pretty sure this has to do with resize handle sizes in bitsdojo_window.
      // If it is not added then the app (according to DevTools) has width < MyTheme.appWidth.
      // TODO(desktop) if display reduces during runtime then the widgets overflow. Has something
      // to do with the border taking up app pixel space.
      const int fudgeTerm = 8 * 2;
      win.minSize = const Size(MyTheme.appWidth + fudgeTerm, MyTheme.appMinHeight);
      win.maxSize = const Size(MyTheme.appWidth + fudgeTerm, 100000);
      win.size = const Size(MyTheme.appWidth + fudgeTerm, MyTheme.appMinHeight + 350);
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

  // just a quick hack
  static bool initialized = false;
  static AdvancedSolver solver = AdvancedSolver();
  static ScheduleProviderDesktop? provider;
  static OptimizerController? optimizerController;

  static ScheduleProvider getScheduleProvider(
    InventoryController inv,
    OptionsController ops,
    BuildItemsController items,
    // cache controller
  ) {
    assert(!initialized);
    initialized = true;
    provider = ScheduleProviderDesktop(inventory: inv, options: ops, buildItems: items);
    optimizerController = OptimizerController(provider!);
    return provider!;
  }

  static Widget getOptimizerPane() {

    return ChangeNotifierProvider.value(builder: (_, __) => const OptimizerFlyout(), value: optimizerController!);
  }
}
