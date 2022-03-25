import 'package:EveIndy/model/build.dart';
import 'package:EveIndy/model/build_tree_node.dart';
import 'package:EveIndy/cache_database/cache_adapter.dart';
import 'package:EveIndy/model/eve_static_data.dart';
import 'package:EveIndy/model/inventory.dart';
import 'package:EveIndy/model/market.dart';
import 'package:EveIndy/model/context.dart';
import 'package:EveIndy/model/market_order.dart';
import 'package:EveIndy/model/order_filter.dart';
import 'package:EveIndy/model/util.dart';
import 'package:flutter/material.dart';

class BuildAdapter extends ChangeNotifier {
  final Build buildForest;
  final CacheDatabaseAdapter _cache;

  BuildAdapter(this.buildForest, this._cache);

  void setBuildContext(EveBuildContext buildContext) {
    buildForest.setBuildContext(buildContext);
    notifyListeners();
  }

  static List<String> AdvancedMaterialsDisplayColumns = [
    'Runs',
    'Lines',
    'Profit',
    'Cost',
    'Profit %',
    'PPU',
    'Sale PPU',
    'Time',
    'Out m3',
  ];

  List<Map<String, num>> getAdvancedRows(Market market) {
    List<Map<String, num>> ret = [];
    for (var tree in buildForest.getTrees()) {
      final runs = tree.getNumRuns();
      final lines = tree.getNumLines();
      final profit = tree.getProfit(market);
      final cost = tree.getTotalCost(market);
      final numProduced = tree.getNumProduced();
      final ppu = cost / numProduced;
      final salePPU = market.getAvgMaxBuyForQuantity(tree.id, numProduced);
      final profitRatio = profit / cost;
      final buildTime = tree.getTimeToBuildSeconds();
      final outputVolume = EveStaticData.items[tree.id]!.volume * numProduced;
      ret.add(<String, num>{
        'id': tree.id,
        'Runs': runs,
        'Lines': lines,
        'Profit': profit,
        'Cost': cost,
        'Profit %': profitRatio,
        'PPU': ppu,
        'Sale PPU': salePPU,
        'Time': buildTime,
        'Out m3': outputVolume
      });
    }
    return ret;
  }

  static List<String> ProcessedMaterialsDisplayColumns = [
    'Value',
  ];

  List<Map<String, num>> getProcessedRows(Market market) {
    List<Map<String, num>> ret = [];

    var ids = <int>{};
    for (var tree in buildForest.getTrees()) {
      for (var child in tree.root.children.values) {
        final isBuildable = EveStaticData.isBuildable(child.id) && !EveStaticData.isFuelBlock(child.id);
        if (isBuildable) {
          ids.add(child.id);
        }
      }
    }

    var values = <int, double>{};
    for (var id in ids) {
      final originalShouldBuild = buildForest.getShouldBuildID(id);
      // set to build and get total cost
      buildForest.setShouldBuildForID(id, true);
      double totalCostWhenBuild = buildForest.getTotalCost(market);
      // set to buy and get total cost
      buildForest.setShouldBuildForID(id, false);
      double totalCostWhenBuy = buildForest.getTotalCost(market);

      buildForest.setShouldBuildForID(id, originalShouldBuild);

      if (originalShouldBuild) {
        values[id] = totalCostWhenBuy - totalCostWhenBuild;
      } else {
        values[id] = totalCostWhenBuild - totalCostWhenBuy;
      }
    }
    for (var id in ids) {
      ret.add(<String, num>{'id': id, 'Value': values[id]!});
    }
    // Default to sorting by name
    return ret..sort((a, b) => a['Value']!.compareTo(b['Value']!));
  }

  void setNumRuns(int id, int numRuns, {updateCache = true}) {
    buildForest.setNumRunsForID(id, numRuns);
    if (updateCache) {
      _cache.setReactions(buildForest.getIdRunsLines());
      notifyListeners();
    }
  }

  void setNumLines(int id, int numLines, {updateCache = true}) {
    buildForest.setNumLinesForID(id, numLines);
    if (updateCache) {
      _cache.setReactions(buildForest.getIdRunsLines());
      notifyListeners();
    }
  }

  void removeTree(int id, {updateCache = true}) {
    buildForest.removeTree(id);
    if (updateCache) {
      _cache.setReactions(buildForest.getIdRunsLines());
      // intermediates that are used in the build could change here
      // so update the db here to make sure it does not contain ids for
      // intermediates that are not in the build. Not sure if this is necessary
      _cache.setIntermediatesToBuy(buildForest.getIntermediatesToBuy());
      notifyListeners();
    }
  }

  void addTree(int id, int numRuns, int numLines, {updateCache = true}) {
    if (buildForest.addTree(id, numRuns, numLines)) {
      if (updateCache) {
        _cache.setReactions(buildForest.getIdRunsLines());
        notifyListeners();
      }
    }
  }

  bool getShouldBuildForID(int id) {
    return buildForest.getShouldBuildID(id);
  }

  void setShouldBuildForID(int id, bool buildOrBuy, {bool updateCache = true}) {
    buildForest.setShouldBuildForID(id, buildOrBuy);
    if (updateCache) {
      _cache.setIntermediatesToBuy(buildForest.getIntermediatesToBuy());
      notifyListeners();
    }
  }

  void clearInventory({updateCache = true}) {
    setInventory(Inventory.empty(), updateCache: updateCache);
  }

  void setInventoryFromStr(String str, {updateCache = true}) {
    Inventory inventory = Inventory(str);
    setInventory(inventory, updateCache: updateCache);
  }

  void setInventory(Inventory inventory, {updateCache = true}) {
    buildForest.setInventory(inventory);
    if (updateCache) {
      _cache.setInventory(inventory.getQuantities());
      notifyListeners();
    }
  }

  String getMultibuyString() {
    var bill = buildForest.getBillOfMaterials();
    String ret = '';
    for (var itemID in bill.keys.toList()..sort()) {
      if (bill[itemID]! > 0) {
        ret += EveStaticData.getName(itemID) + '\t' + bill[itemID]!.toString() + '\n';
      }
    }
    return ret;
  }

  String getOutputInfo(Market market) {
    String ret = "Final Products\n";
    for (var entry in buildForest.getProducedItems().entries) {
      int id = entry.key;
      ret = ret + EveStaticData.getName(id) + ' ' + entry.value.toString() + '\n';
    }
    ret += '\nExcess Items\n';
    for (var entry in buildForest.getExcessItems().entries) {
      int id = entry.key;
      if (entry.value > 0) {
        ret = ret + EveStaticData.getName(id) + ' ' + entry.value.toString() + '\n';
      }
    }
    bool hasPrintedHeader = false;
    for (var entry in buildForest.getMutatedInventoryClone().getQuantities().entries) {
      int id = entry.key;
      if (entry.value > 0) {
        if (!hasPrintedHeader) {
          ret += '\nRemaining Inventory\n';
          hasPrintedHeader = true;
        }
        ret = ret + EveStaticData.getName(id) + ' ' + entry.value.toString() + '\n';
      }
    }
    return ret;
  }

  String getBuildString() {
    String str = '';
    int w = 25;
    var getLine = (Node n) {
      String name = EveStaticData.getName(n.id);
      String namePad = ' ' * (w - name.length);

      int baseTime = EveStaticData.blueprints[n.id]!.baseTimePerRunSeconds;
      int quo = (n.numRuns ~/ n.numLines);
      int rem = (n.numRuns % n.numLines);
      double days = calcBonusedTimeSeconds((quo + (rem > 0 ? 1 : 0)), baseTime, 5, .22) / (3600 * 24);

      return (name +
          namePad +
          // '\tR: ' +
          // n.numRuns.toString() +
          '\t' +
          n.numLines.toString() +
          ', ' +
          quo.toString() +
          ', ' +
          rem.toString() +
          // '  t:' +
          // prettyPrintSecondsToDH(n.getTimeToBuildFullTreeSeconds()) +
          '  t:' +
          days.toStringAsFixed(5) +
          '\n');
    };
    str += "\t\t\t(Lines, Runs, Remainder)\n\n";
    for (var tree in buildForest.getTrees()) {
      str += getLine(tree.root);
      for (var child in tree.root.children.values) {
        if (child.shouldBuild && child.numLines > 0) {
          str += '    ' + getLine(child);
        }
      }
      str += '\n';
    }
    return str;
  }

  Future<void> _loadBuiltReactionsFromCache() async {
    for (var element in await _cache.getReactions()) {
      addTree(element.item1, element.item2, element.item3, updateCache: false);
    }
  }

  Future<void> _loadBuildBuySelectionsFromCache() async {
    for (int id in await _cache.getIntermediatesToBuy()) {
      setShouldBuildForID(id, false, updateCache: false);
    }
  }

  Future<void> _loadInventoryFromCache() async {
    final inv = await _cache.getInventoryItemsAndQuantities();
    setInventory(Inventory.fromMap(inv), updateCache: false);
  }

  Future<void> loadFromCache() async {
    await _loadBuiltReactionsFromCache();
    await _loadBuildBuySelectionsFromCache();
    await _loadInventoryFromCache();
    notifyListeners();
  }

  bool isInventoryEmpty() {
    return buildForest.isInventoryEmpty();
  }
}

class MarketAdapter extends ChangeNotifier {
  final Market market;
  final CacheDatabaseAdapter _cache;

  MarketAdapter(this.market, this._cache);

  OrderFilter getOrderFilter(bool buy) {
    return market.getOrderFilter(buy);
  }

  Future<void> updateOrderFilter(List<int> systemIds, bool isBuy) async {
    final filter = OrderFilter(systemIds);
    market.setMarketFilter(filter, isBuy);
    await _cache.setOrderFilter(filter, isBuy);
    notifyListeners();
  }

  void setMarketLogs(Map<String, String> marketLogsName2Content) {
    market.loadMarketLogs(marketLogsName2Content);
    Map<int, List<Order>> orders = market.getAsMap();
    _cache.setOrders(orders);
    notifyListeners();
  }

  Future<void> loadFromCache() async {
    final orders = await _cache.getOrders();
    market.setOrders(orders);
    market.setMarketFilter(await _cache.getOrderFilter(false), false);
    market.setMarketFilter(await _cache.getOrderFilter(true), true);
    notifyListeners();
  }
}

class EveBuildContextAdapter extends ChangeNotifier {
  EveBuildContext buildContext;
  final CacheDatabaseAdapter _cache;

  EveBuildContextAdapter(this.buildContext, this._cache);

  Future<void> _setBuildContext(EveBuildContext ctx, BuildAdapter buildAdapter, {bool updateCache = true}) async {
    buildContext = ctx;
    buildAdapter.setBuildContext(buildContext);
    if (updateCache) {
      await _cache.setBuildContext(buildContext);
      notifyListeners();
    }
  }

  Future<void> setReactionSkillLevel(int parse, BuildAdapter buildAdapter) async {
    await _setBuildContext(
        EveBuildContext(parse, buildContext.structureMaterialBonus, buildContext.structureTimeBonus, buildContext.systemCostIndex,
            buildContext.salesTaxPercent, buildContext.brokersFeePercent),
        buildAdapter);
  }

  Future<void> setStructureMaterialBonus(double parse, BuildAdapter buildAdapter) async {
    await _setBuildContext(
        EveBuildContext(buildContext.reactionSkillLevel, parse, buildContext.structureTimeBonus, buildContext.systemCostIndex,
            buildContext.salesTaxPercent, buildContext.brokersFeePercent),
        buildAdapter);
  }

  Future<void> setStructureTimeBonus(double parse, BuildAdapter buildAdapter) async {
    await _setBuildContext(
        EveBuildContext(buildContext.reactionSkillLevel, buildContext.structureMaterialBonus, parse, buildContext.systemCostIndex,
            buildContext.salesTaxPercent, buildContext.brokersFeePercent),
        buildAdapter);
  }

  Future<void> setSystemReactionCostIndex(double parse, BuildAdapter buildAdapter) async {
    await _setBuildContext(
        EveBuildContext(buildContext.reactionSkillLevel, buildContext.structureMaterialBonus, buildContext.structureTimeBonus, parse,
            buildContext.salesTaxPercent, buildContext.brokersFeePercent),
        buildAdapter);
  }

  Future<void> setSalesTaxPercent(double parse, BuildAdapter buildAdapter) async {
    await _setBuildContext(
        EveBuildContext(buildContext.reactionSkillLevel, buildContext.structureMaterialBonus, buildContext.structureTimeBonus,
            buildContext.systemCostIndex, parse, buildContext.brokersFeePercent),
        buildAdapter);
  }

  Future<void> loadFromCache(BuildAdapter buildAdapter) async {
    final eveBuildContext = await _cache.getBuildContext();
    if (eveBuildContext == null) {
      return;
    }
    await _setBuildContext(eveBuildContext, buildAdapter, updateCache: false);
  }
}
