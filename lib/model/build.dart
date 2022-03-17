import 'dart:math';
import 'package:tuple/tuple.dart';

import 'build_tree.dart';
import 'context.dart';
import 'eve_static_data.dart';
import 'inventory.dart';
import 'market.dart';
import 'util.dart';

class Build {
  EveBuildContext _context;

  Inventory _inventoryOriginal = Inventory.empty();
  Inventory _inventoryMutated = Inventory.empty();

  final Map<int, BuildTree> _forest = {};

  Build(this._context);

  void setShouldBuildForID(int id, bool shouldBuild) {
    for (var tree in _forest.values) {
      tree.setShouldBuildID(id, shouldBuild);
    }
    _refreshForestState();
  }

  void setNumRunsForID(int id, int numRuns) {
    for (var tree in _forest.values) {
      if (tree.root.id == id) {
        tree.setNumRuns(numRuns);
      }
    }
    _refreshForestState();
  }

  void setNumLinesForID(int id, int numLines) {
    for (var tree in _forest.values) {
      if (tree.root.id == id) {
        tree.setNumLines(numLines);
      }
    }
    _refreshForestState();
  }

  void setBuildContext(ctx) {
    _context = ctx;
    _refreshForestState();
  }

  void _refreshForestState() {
    _inventoryMutated = Inventory.cloneOf(_inventoryOriginal);
    for (var tree in _forest.values) {
      tree.refreshTreeState(_inventoryMutated);
    }
  }

  void removeTree(int id) {
    _forest.remove(id);
    _refreshForestState();
  }

  bool addTree(int id, int numRuns, int numLines) {
    if (_forest.containsKey(id)) {
      return false;
    }
    _forest[id] = BuildTree(id, numRuns, numLines, _inventoryMutated, () => _context);
    return true;
  }

  Map<int, int> getBillOfMaterials() {
    Map<int, int> bill = {};
    for (var tree in _forest.values) {
      combineMaps(bill, tree.getBillOfMaterials());
    }
    return bill;
  }

  double getTotalJobInstallCost(Market market) {
    double cost = 0.0;
    for (var tree in _forest.values) {
      cost += tree.getTotalJobInstallationCost(market.adjustedPrices);
    }
    return cost;
  }

  double getTotalMaterialCost(Market market) {
    final bill = getBillOfMaterials();
    final costs = market.getAvgMinSellForShoppingList(bill);
    return bill.entries.fold(0.0, (double s, x) => s + costs[x.key]! * x.value);
  }

  double getTotalCost(Market market) {
    double jobInstallCost = getTotalJobInstallCost(market);
    double totalMaterialCost = getTotalMaterialCost(market);
    return jobInstallCost + totalMaterialCost;
  }

  double getTotalProfit(Market market) {
    double profit = 0.0;
    for (var tree in _forest.values) {
      profit += tree.getProfit(market);
    }
    return profit;
  }

  double getTotalBuildTimeSeconds() {
    double buildTime = 0.0;
    for (var tree in _forest.values) {
      buildTime = max(tree.getTimeToBuildSeconds(), buildTime);
    }
    return buildTime;
  }

  double getInputVolume() {
    var materials = getBillOfMaterials();
    double inputVolume = 0.0;
    for (var matID in materials.keys) {
      inputVolume += EveStaticData.items[matID]!.volume * materials[matID]!;
    }
    return inputVolume;
  }

  double getOutputVolume() {
    double outputVolume = 0.0;
    for (var id in _forest.keys) {
      outputVolume += EveStaticData.items[id]!.volume * _forest[id]!.getNumRuns() * EveStaticData.blueprints[id]!.numProducedPerRun;
    }
    return outputVolume;
  }

  bool getShouldBuildID(int id) {
    for (var tree in _forest.values) {
      for (var child in tree.root.children.values) {
        if (child.id == id) {
          return child.shouldBuild;
        }
      }
    }
    assert(false);
    return false;
  }

  List<BuildTree> getTrees() {
    return _forest.values.toList()..sort((a, b) => EveStaticData.getName(a.id).compareTo(EveStaticData.getName(b.id)));
  }

  Inventory getMutatedInventoryClone() {
    return Inventory.cloneOf(_inventoryMutated);
  }

  Inventory getOriginalInventoryClone() {
    return Inventory.cloneOf(_inventoryOriginal);
  }

  void clearInventory() {
    _inventoryOriginal = Inventory.empty();
    _refreshForestState();
  }

  void setInventory(Inventory inv) {
    _inventoryOriginal = inv;
    _refreshForestState();
  }

  Map<int, int> getProducedItems() {
    Map<int, int> ret = {};
    for (var tree in _forest.values) {
      if (!ret.containsKey(tree.id)) {
        ret[tree.id] = 0;
      }
      ret[tree.id] = ret[tree.id]! + EveStaticData.blueprints[tree.id]!.numProducedPerRun * tree.getNumRuns();
    }
    return ret;
  }

  Map<int, int> getExcessItems() {
    Map<int, int> ret = {};
    for (var tree in _forest.values) {
      combineMaps(ret, tree.getExcessMats());
    }
    return ret;
  }

  Iterable<Tuple3<int, int, int>> getIdRunsLines() {
    return _forest.values.map((t) => Tuple3(t.id, t.root.numRuns, t.root.numLines));
  }

  Iterable<int> getIntermediatesToBuy() {
    var ids = <int>{};
    for (var tree in _forest.values) {
      for (var child in tree.root.children.values) {
        if (!child.shouldBuild && EveStaticData.isBuildable(child.id) && !EveStaticData.isFuelBlock(child.id)) {
          ids.add(child.id);
        }
      }
    }
    return ids;
  }

  bool isInventoryEmpty() {
    return _inventoryOriginal.getQuantities().isEmpty;
  }

  Map<int, double> getPPUs(Market market) {
    Map<int, double> ret = {};
    for (var tree in _forest.values) {
      int numProduced = EveStaticData.blueprints[tree.id]!.numProducedPerRun * tree.getNumRuns();
      ret[tree.id] = tree.getTotalCost(market) / numProduced;
    }
    return ret;
  }
}
