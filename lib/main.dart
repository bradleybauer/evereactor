
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/controllers.dart';
import 'gui/main.dart';
import 'gui/my_theme.dart';
import 'persistence/persistence.dart';
import 'platform.dart';
import 'strings.dart';

Future<void> main() async {
  final persistence = Persistence();

  final MyTheme myTheme = MyTheme(persistence);
  final Strings strings = Strings();

  final inventory = InventoryController();
  final options = OptionsController(persistence, strings);
  final buildItems = BuildItemsController(persistence);
  final scheduleProvider = Platform.getScheduleProvider(inventory, options, buildItems);
  final build = Build(scheduleProvider);
  final basicBuild = BasicBuild(options, buildItems);

  final market = MarketController(persistence);

  final targetsTableController = TargetsTableController(market, build, buildItems, options, strings);
  final intermediatesTableController = IntermediatesTableController(market, buildItems, options, basicBuild, strings);
  final inputsTableController = InputsTableController(market, build, strings);
  final searchController = SearchController(market, buildItems, basicBuild, options, strings);
  final summaryController = SummaryController(market, buildItems, build, options, strings);

  await myTheme.loadFromCache();
  await options.loadFromCache();
  await market.loadFromCache();
  await buildItems.loadFromCache();

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
