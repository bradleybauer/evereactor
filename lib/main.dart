import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/controllers.dart';
import 'gui/main.dart';
import 'gui/my_theme.dart';
import 'platform.dart';
import 'strings.dart';

Future<void> main() async {
  // final cacheDbController = Persistence

  // Make models
  // Make controllers & load model data from cache through them
  // Info loaded from cache is market, orderfilter, context, lines&runs, inventory
  // final market = MarketController(market, cacheDbContro
  // await marketController.loadFromCache

  // final buildController = BuildController(Build(eveBuildContext), cacheDbCon
  // await buildController.loadFromCache

  // final eveBuildContextController = EveBuildContextController(eveBuildContext, cacheDbCon
  // await eveBuildContextController.loadFromCache(buildContro

  // Some change notifiers and widgets want to be notified when the language changes
  final MyTheme myTheme = MyTheme();
  final Strings strings = Strings();

  final market = MarketController();
  final inventory = InventoryController();
  final options = OptionsController(strings);
  final buildItems = BuildItemsController();
  final build = Build(inventory, options, buildItems);
  final basicBuild = BasicBuild(options, buildItems);
  final targetsTableController = TargetsTableController(market, build, buildItems, options, strings);
  final intermediatesTableController = IntermediatesTableController(market, buildItems, options, basicBuild, strings);
  final inputsTableController = InputsTableController(market, build, strings);
  final searchController = SearchController(market, buildItems, basicBuild, options, strings);
  final summaryController = SummaryController(market, buildItems, build, options, strings);

  Platform.appReadyHook();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: myTheme),
      ChangeNotifierProvider.value(value: strings),
      ChangeNotifierProvider.value(value: build),
      ChangeNotifierProvider.value(value: searchController),
      ChangeNotifierProvider.value(value: targetsTableController),
      ChangeNotifierProvider.value(value: intermediatesTableController),
      ChangeNotifierProvider.value(value: inputsTableController),
      ChangeNotifierProvider.value(value: buildItems),
      ChangeNotifierProvider.value(value: options),
      ChangeNotifierProvider.value(value: market),
      ChangeNotifierProvider.value(value: summaryController),
    ],
    child: const MyApp(),
  ));
}

// background on web

// decoration: BoxDecoration(
//   gradient: LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     // end: Alignment(0, 0),
//     stops: [0.0, .5, 0.5, 1],
//     colors: [
//       // Colors.blue,
//       // Colors.red,
//       // Colors.blue,
//       // Colors.red,

//       // Colors.white,
//       // Colors.grey,
//       // Colors.white,
//       // Colors.grey,

//       Color(0x88ECEFF1),
//       Color(0x88ECEFF1),
//       Color(0xFFFAFAFA),
//       Color(0xFFFAFAFA),
//     ],
//     tileMode: TileMode.repeated,
//   ),
// ),
