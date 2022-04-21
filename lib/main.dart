import 'package:EveIndy/gui/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'adapters/search.dart';
import 'platform.dart';

Future<void> main() async {
  // final cacheDbAdapter = Persistence();

  // Make models
  // final eveBuildContext = EveBuildContext(5, .022, .22, 3 / 100, 3.6 / 100, 1.2);
  // final market = Market();
  // await market.loadAdjustedPricesFromESI();

  // Make adapters & load model data from cache through them
  // Info loaded from cache is market, orderfilter, context, lines&runs, inventory
  // final marketAdapter = MarketAdapter(market, cacheDbAdapter);
  // await marketAdapter.loadFromCache();

  // final buildAdapter = BuildAdapter(Build(eveBuildContext), cacheDbAdapter);
  // await buildAdapter.loadFromCache();

  // final eveBuildContextAdapter = EveBuildContextAdapter(eveBuildContext, cacheDbAdapter);
  // await eveBuildContextAdapter.loadFromCache(buildAdapter);

  final searchAdapter = SearchAdapter();

  Platform.appReadyHook();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: searchAdapter),
      //     ChangeNotifierProvider.value(value: marketAdapter),
      //     ChangeNotifierProvider.value(value: eveBuildContextAdapter),
    ],
    child: const MyApp(),
  ));
}

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
