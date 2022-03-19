import 'package:app/gui/overlay_menu.dart';
import 'package:app/model/order_filter.dart';
import 'package:app/model/util.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'adapters.dart';
import 'form_fields.dart';
import 'labeled_checkbox.dart';
import 'table.dart';

class MainPageContent extends StatefulWidget {
  const MainPageContent({Key? key}) : super(key: key);

  @override
  _MainPageContentState createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  static const double width = 945;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Header(width),
          Expanded(
            child: Scrollbar(
              isAlwaysShown: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                      child: const BuildSummary(width),
                    ),
                    // Stack(
                    //   alignment: Alignment.center,
                    //   children: [
                    //     Column(
                    //       children: [
                    //         const Header(width),
                    //         Padding(
                    //           padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                    //           child: SizedBox(
                    //             // child: Container(color: Colors.grey[400]),
                    //             width: width * .8,
                    //             height: .5,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     const Positioned(bottom: 0, child: BuildSummary(width)),
                    //   ],
                    // ),
                    BuildTablesView(width),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header(this.width, {Key? key}) : super(key: key);

  final double width;
  final double height = 132;

  @override
  Widget build(BuildContext context) {
    Widget pasteOrClear = Provider.of<BuildAdapter>(context).isInventoryEmpty()
        ? TextField(
            onChanged: (s) => Provider.of<BuildAdapter>(context, listen: false).setInventoryFromStr(s),
            maxLines: null,
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE0E0E0))),
              fillColor: Colors.white,
              filled: true,
              labelText: 'Paste Inventory',
              labelStyle: TextStyle(fontSize: 14),
              // label: Center(child: Text('Paste Inventory')), does not look good
              contentPadding: EdgeInsets.all(9),
              isDense: true,
              border: OutlineInputBorder(),
            ))
        : OutlinedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: () => Provider.of<BuildAdapter>(context, listen: false).clearInventory(),
            child: const Text('Clear Inventory'));

    pasteOrClear = ConstrainedBox(constraints: const BoxConstraints.tightForFinite(width: 148, height: 28), child: pasteOrClear);

    return Container(
      color: Color.fromARGB(55, 250, 250, 250),
      // color: Colors.transparent,
      constraints: BoxConstraints.tightFor(height: height, width: width),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: SizedBox(
                  width: 250,
                  height: height,
                  // color: Colors.grey[200],
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('EveIndy', style: TextStyle(fontSize: 32, color: Colors.grey[800])),
                    // child: Text('EVE Isk per Hour', style: TextStyle(fontSize: 32, color: Colors.grey[800])),
                  ),
                ),
              ),
              left: 0),
          SizedBox.expand(child: WindowTitleBarBox(child: MoveWindow())),
          Positioned(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        OutlinedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            onPressed: () {
                              FilePicker.platform
                                  .pickFiles(allowMultiple: true, allowedExtensions: ['txt'], type: FileType.custom, withData: true)
                                  .then((result) {
                                if (result == null) {
                                  return;
                                }
                                Map<String, String> marketLogsName2Content = {};
                                for (int i = 0; i < result.files.length; i++) {
                                  if (result.files[i].bytes == null) {
                                    continue;
                                  }
                                  marketLogsName2Content[result.files[i].name] = String.fromCharCodes(result.files[i].bytes!);
                                }
                                Provider.of<MarketAdapter>(context, listen: false).setMarketLogs(marketLogsName2Content);
                              });
                            },
                            child: const Text('Load Market Logs')),
                        SizedBox(width: 14),
                        pasteOrClear,
                        SizedBox(width: 14),
                        OverlayMenu(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(width: 400),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                                child: FocusTraversalGroup(child: EveBuildContextView()),
                              ),
                              FocusTraversalGroup(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                                            child: FocusTraversalGroup(child: const MarketHubs())),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ElevatedButton(
                        //   onPressed: () {},
                        //   child: const Text('Options'),
                        //   style: ButtonStyle(
                        //       backgroundColor: MaterialStateProperty.all(Colors.white),
                        //       foregroundColor: MaterialStateProperty.all(Colors.blue),
                        //       elevation: MaterialStateProperty.resolveWith((states) {
                        //         if (states.contains(MaterialState.hovered)) return 12.0;
                        //       })),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            onPressed: () {
                              String str = Provider.of<BuildAdapter>(context, listen: false).getBuildString();
                              if (str == '') {
                                return;
                              }
                              Clipboard.setData(ClipboardData(text: str));
                            },
                            child: const Text('Copy Build Plan')),
                        const SizedBox(width: 14),
                        OutlinedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            onPressed: () {
                              var str = Provider.of<BuildAdapter>(context, listen: false).getMultibuyString();
                              if (str == '') {
                                return;
                              }
                              Clipboard.setData(ClipboardData(text: str));
                            },
                            child: const Text('Copy MutliBuy')),
                        const SizedBox(width: 14),
                        OutlinedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            onPressed: () {
                              final market = Provider.of<MarketAdapter>(context, listen: false).market;
                              var str = Provider.of<BuildAdapter>(context, listen: false).getOutputInfo(market);
                              if (str == '') {
                                return;
                              }
                              Clipboard.setData(ClipboardData(text: str));
                            },
                            child: const Text('Copy Products')),
                      ],
                    ),
                  ],
                ),
              ),
              right: 0),
        ],
      ),
    );
  }
}

class BuildTablesView extends StatelessWidget {
  const BuildTablesView(this.width, {Key? key}) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) {
    return Consumer3<BuildAdapter, MarketAdapter, EveBuildContextAdapter>(
      builder: (_, buildAdapter, marketAdapter, evecontext, __) {
        var advancedMaterialsData = buildAdapter.getAdvancedRows(marketAdapter.market);
        var processedMaterialsData = buildAdapter.getProcessedRows(marketAdapter.market);
        return ChangeNotifierProvider(
          create: (context) => RowHighlightNotifier(),
          child: SizedBox(
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(width: width * .8, child: Divider(height: 1, color: Colors.grey[300])),
                SizedBox(
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: FocusTraversalGroup(child: AdvancedMaterialsTable(data: advancedMaterialsData, buildAdapter: buildAdapter)),
                  ),
                ),
                // SizedBox(width: width * .8, child: Divider(height: 1, color: Colors.grey[300])),
                Container(
                  color: Color.fromARGB(55, 250, 250, 250),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: width / 2 - 1,
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child:
                                  HeuristicTable(buildAdapter: buildAdapter, market: marketAdapter.market, buildCtx: evecontext.buildContext),
                            ),
                          ),
                          SizedBox(
                            width: width / 2 - 1,
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: ProcessedMaterialTable(data: processedMaterialsData, buildAdapter: buildAdapter),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: width,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: width / 2,
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: InventoryTable(buildAdapter: buildAdapter, marketAdapter: marketAdapter),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class BuildSummary extends StatelessWidget {
  const BuildSummary(this.width, {Key? key}) : super(key: key);

  final double width;

  static const double pad = 32;
  Widget getWidget(s, s1, ctx) {
    return SizedBox(
        height: pad,
        child: Center(
            child: Row(
          children: [Text(s + ' ', style: const TextStyle(fontWeight: FontWeight.bold)), Text(s1)],
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BuildAdapter, MarketAdapter>(builder: (_, build, market, __) {
      // double totalCost = build.buildForest.getTotalCost(market.market);
      double totalJobCost = build.buildForest.getTotalJobInstallCost(market.market);
      double totalMaterialCost = build.buildForest.getTotalMaterialCost(market.market);
      double totalProfit = build.buildForest.getTotalProfit(market.market);
      double inputVolume = build.buildForest.getInputVolume();
      double outputVolume = build.buildForest.getOutputVolume();
      // double profitRatio = totalProfit / totalCost;
      // double iph = totalProfit / (build.buildForest.getTotalBuildTimeSeconds() / 3600);
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300] as Color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: pad / 4, horizontal: pad),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 115, child: getWidget('Profit: ', currencyFormatNumber(totalProfit), context)),
              SizedBox(width: 100, child: getWidget('Jobs: ', currencyFormatNumber(totalJobCost), context)),
              SizedBox(width: 120, child: getWidget('Mats: ', currencyFormatNumber(totalMaterialCost), context)),
              SizedBox(width: 105, child: getWidget('In m3: ', volumeNumberFormat(inputVolume), context)),
              SizedBox(width: 100, child: getWidget('Out m3: ', volumeNumberFormat(outputVolume), context)),
              // getWidget('Profit Ratio: ' + percentFormat(profitRatio)),
              // getWidget('IPH: ' + currencyFormatNumber(iph)),
            ],
          ),
        ),
      );
    });
  }
}

class MarketHubs extends StatelessWidget {
  const MarketHubs({Key? key}) : super(key: key);

  void Function(bool?) getCallBack(BuildContext context, int systemId, List<int> currentFilteredSystemIds, bool isBuy) {
    return (b) async {
      List<int> newFilteredSystemIds = [...currentFilteredSystemIds];
      if (b == null || !b) {
        if (newFilteredSystemIds.contains(systemId)) {
          newFilteredSystemIds.remove(systemId);
        }
      } else if (!newFilteredSystemIds.contains(systemId)) {
        newFilteredSystemIds.add(systemId);
      }
      Provider.of<MarketAdapter>(context, listen: false).updateOrderFilter(newFilteredSystemIds, isBuy);
    };
  }

  @override
  Widget build(BuildContext context) {
    const double pad = 32;

    List<String> systemNames = OrderFilter.possibleSystems.values.toList();
    List<int> systemIds = OrderFilter.possibleSystems.keys.toList();
    List<int> currentBuySystemIds = Provider.of<MarketAdapter>(context).getOrderFilter(false).systems; // get(false) gets filter for sell orders
    List<int> currentSellSystemIds = Provider.of<MarketAdapter>(context).getOrderFilter(true).systems; // get(true) gets filter for buy orders

    List<Widget> buyWidgets = [];
    for (int j = 0; j < OrderFilter.possibleSystems.length; j++) {
      buyWidgets.add(SizedBox(
          height: pad,
          child: LabeledCheckbox(
              label: systemNames[j],
              value: currentBuySystemIds.contains(systemIds[j]),
              onChanged: getCallBack(context, systemIds[j], currentBuySystemIds, false))));
    }
    List<Widget> sellWidgets = [];
    for (int j = 0; j < OrderFilter.possibleSystems.length; j++) {
      sellWidgets.add(SizedBox(
          height: pad,
          child: LabeledCheckbox(
              label: systemNames[j],
              value: currentSellSystemIds.contains(systemIds[j]),
              onChanged: getCallBack(context, systemIds[j], currentSellSystemIds, true))));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Buy Markets', style: Theme.of(context).textTheme.subtitle1),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: buyWidgets.sublist(0, systemNames.length ~/ 2),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: buyWidgets.sublist(systemNames.length ~/ 2),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Sell Markets', style: Theme.of(context).textTheme.subtitle1),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: sellWidgets.sublist(0, systemNames.length ~/ 2),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: sellWidgets.sublist(systemNames.length ~/ 2),
            ),
          ],
        )
      ],
    );
  }
}

// This must be stateful to prevent reconstructing the formKey when the widget rebuilds I think.
class EveBuildContextView extends StatefulWidget {
  const EveBuildContextView({Key? key}) : super(key: key);

  @override
  State<EveBuildContextView> createState() => _EveBuildContextViewState();
}

class _EveBuildContextViewState extends State<EveBuildContextView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var build = Provider.of<BuildAdapter>(context, listen: false);
    var ctx = Provider.of<EveBuildContextAdapter>(context, listen: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 8),
              SettingsIntegerInputFormField(
                formKey: _formKey,
                initialValue: ctx.buildContext.reactionSkillLevel.toString(),
                labelText: 'Reactions Skill Level',
                maxNumDigits: 1,
                validator: (String? s) {
                  if (s == null || s.isEmpty || int.parse(s) > 5 || int.parse(s) < 1) {
                    return 'Enter an integer between 1 and 5';
                  }
                  var newVal = int.parse(s);
                  if (newVal == ctx.buildContext.reactionSkillLevel) return null;
                  ctx.setReactionSkillLevel(newVal, build);
                },
              ),
              const SizedBox(height: 16),
              PercentInputFormField(
                formKey: _formKey,
                initialValue: currencyFormatNumber(ctx.buildContext.structureMaterialBonus * 100,
                    roundBigIskToMillions: false, roundFraction: false, removeFraction: false, removeZeroFractionFromString: false),
                labelText: 'Structure Material Bonus',
                validator: (String? s) {
                  if (s == null || s.isEmpty || s == '.' || double.parse(s) > 100) {
                    // return 'Enter a number between 0 and 100';
                    return 'Enter a number between 0 and 100';
                  }
                  var newVal = double.parse(s) / 100;
                  if (newVal == ctx.buildContext.structureMaterialBonus) return null;
                  ctx.setStructureMaterialBonus(double.parse(s) / 100, build);
                },
              ),
              const SizedBox(height: 16),
              PercentInputFormField(
                formKey: _formKey,
                initialValue: currencyFormatNumber(ctx.buildContext.structureTimeBonus * 100,
                    roundBigIskToMillions: false, roundFraction: false, removeFraction: false, removeZeroFractionFromString: false),
                labelText: 'Structure Time Bonus',
                validator: (String? s) {
                  if (s == null || s.isEmpty || s == '.' || double.parse(s) > 100) {
                    return 'Enter a number between 0 and 100';
                  }
                  var newVal = double.parse(s) / 100;
                  if (newVal == ctx.buildContext.structureTimeBonus) return null;
                  ctx.setStructureTimeBonus(double.parse(s) / 100, build);
                },
              ),
              const SizedBox(height: 16),
              PercentInputFormField(
                formKey: _formKey,
                initialValue: currencyFormatNumber(ctx.buildContext.systemCostIndex * 100,
                    roundBigIskToMillions: false, roundFraction: false, removeFraction: false, removeZeroFractionFromString: false),
                labelText: 'System Cost Index',
                validator: (String? s) {
                  if (s == null || s.isEmpty || s == '.') {
                    return 'Enter a decimal number';
                  }
                  var newVal = double.parse(s) / 100;
                  if (newVal == ctx.buildContext.systemCostIndex) return null;
                  ctx.setSystemReactionCostIndex(double.parse(s) / 100, build);
                },
              ),
              const SizedBox(height: 16),
              PercentInputFormField(
                formKey: _formKey,
                initialValue: currencyFormatNumber(ctx.buildContext.salesTaxPercent * 100,
                    roundBigIskToMillions: false, roundFraction: false, removeFraction: false),
                labelText: 'Sales Tax Percent',
                validator: (String? s) {
                  if (s == null || s.isEmpty || s == '.' || double.parse(s) > 100.0) {
                    return 'Enter a decimal between 0 and 100';
                  }
                  var newVal = double.parse(s) / 100;
                  if (newVal == ctx.buildContext.salesTaxPercent) return null;
                  ctx.setSalesTaxPercent(double.parse(s) / 100, build);
                },
              ),
            ],
          ),
        ),
      ],
    );
    ;
  }
}
