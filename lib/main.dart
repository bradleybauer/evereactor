import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'adapters/build.dart';
import 'adapters/build_items.dart';
import 'adapters/inventory.dart';
import 'adapters/market.dart';
import 'adapters/options.dart';
import 'adapters/search.dart';
import 'adapters/table_inputs.dart';
import 'adapters/table_intermediates.dart';
import 'adapters/table_targets.dart';
import 'gui/main.dart';
import 'gui/my_theme.dart';
import 'platform.dart';
import 'strings.dart';
import 'misc.dart';

Future<void> main() async {
  // final cacheDbAdapter = Persistence();

  // Make models
  // final market = Market();
  // await market.loadAdjustedPricesFromESI();

  // Make adapters & load model data from cache through them
  // Info loaded from cache is market, orderfilter, context, lines&runs, inventory
  // final market = MarketAdapter(market, cacheDbAdapter);
  // await marketAdapter.loadFromCache();

  // final buildAdapter = BuildAdapter(Build(eveBuildContext), cacheDbAdapter);
  // await buildAdapter.loadFromCache();

  // final eveBuildContextAdapter = EveBuildContextAdapter(eveBuildContext, cacheDbAdapter);
  // await eveBuildContextAdapter.loadFromCache(buildAdapter);

  // Some change notifiers and widgets want to be notified when the language changes
  final Strings strings = Strings();

  final MyTheme myTheme = MyTheme();

  final market = MarketAdapter();

  final inventory = InventoryAdapter();
  final options = OptionsAdapter(market, strings);
  final buildItems = BuildItemsAdapter();
  final build = Build(inventory, options, buildItems);

  final searchAdapter = SearchAdapter(buildItems, strings);
  final targetsTableAdapter = TargetsTableAdapter(market, build, buildItems, strings);
  final intermediatesTableAdapter = IntermediatesTableAdapter(market, build, strings);
  final inputsTableAdapter = InputsTableAdapter(market, build, strings);

  Platform.appReadyHook();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: myTheme),
      ChangeNotifierProvider.value(value: strings),
      ChangeNotifierProvider.value(value: build),
      ChangeNotifierProvider.value(value: searchAdapter),
      ChangeNotifierProvider.value(value: targetsTableAdapter),
      ChangeNotifierProvider.value(value: intermediatesTableAdapter),
      ChangeNotifierProvider.value(value: inputsTableAdapter),
      ChangeNotifierProvider.value(value: buildItems),
      ChangeNotifierProvider.value(value: options),
      ChangeNotifierProvider.value(value: market),
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
