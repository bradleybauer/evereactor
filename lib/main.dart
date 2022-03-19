import 'package:app/model/build.dart';
import 'package:app/cache_database/cache_adapter.dart';
import 'package:app/model/market.dart';
import 'package:app/model/context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:provider/provider.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'loader/loader_hook.dart';

import 'gui/main.dart';
import 'gui/adapters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  doWhenWindowReady(() {
    final win = appWindow;
    win.alignment = Alignment.centerRight;
    win.title = "EveReactor";
    const sz = Size(945 + 16, 1006);
    // win.maxSize = sz;
    win.minSize = sz;
    win.maxSize = Size(sz.width, 1000000.0);
    win.size = sz;
    win.show();
  });

  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.acrylic,
    // effect: WindowEffect.tabbed,
    // effect: WindowEffect.aero,
    color: Colors.white,
  );

  final cacheDbAdapter = CacheDatabaseAdapter();

  // Make models
  final eveBuildContext = EveBuildContext(5, .022, .22, 3 / 100, 3.6 / 100, 1.2);
  final market = Market();
  await market.loadAdjustedPricesFromESI();

  // Make adapters & load model data from cache through them
  // Info loaded from cache is market, orderfilter, context, lines&runs, inventory
  final marketAdapter = MarketAdapter(market, cacheDbAdapter);
  await marketAdapter.loadFromCache();

  final buildAdapter = BuildAdapter(Build(eveBuildContext), cacheDbAdapter);
  await buildAdapter.loadFromCache();

  final eveBuildContextAdapter = EveBuildContextAdapter(eveBuildContext, cacheDbAdapter);
  await eveBuildContextAdapter.loadFromCache(buildAdapter);

  // Map<int, int> items = buildAdapter.buildForest.getProducedItems();
  // var ids = items.keys.toList();
  // await market.loadPricesFromESI(ids);
  // for (var item in items.entries) {
  //   print(EveStaticData.getName(item.key) +
  //       ' ' +
  //       item.value.toString() +
  //       '\t' +
  //       (market.getAvgMaxBuyForQuantity(item.key, item.value) * item.value / 1000000).toString());
  // }

  LoaderHook.hook();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: buildAdapter),
      ChangeNotifierProvider.value(value: marketAdapter),
      ChangeNotifierProvider.value(value: eveBuildContextAdapter),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Eve Reactor',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: const Scaffold(
          backgroundColor: Colors.transparent,
          // backgroundColor: Color.fromARGB(255, 210, 228, 218),
          // backgroundColor: const Color.fromARGB(255, 245, 249, 247),
          // backgroundColor: Color.fromARGB(255, 240, 240, 240),
          // backgroundColor: Color(0xFFF5F5F5),
          // backgroundColor: Color(0xFF212121),
          // backgroundColor: Colors.white,
          body: MainPageContent(),
        ));
  }
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
