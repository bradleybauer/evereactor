import 'package:EveIndy/model/market.dart';
import 'eve_static_data.dart';
import 'build_tree_node.dart';
import 'context.dart';
import 'inventory.dart';
import 'line_allocator.dart';
import 'util.dart';

import 'package:tuple/tuple.dart';

class BuildTree {
  final EveBuildContext Function() _getContext;

  final int id;
  final Node root;

  Map<int, int>? rootBillCache;

  BuildTree(this.id, int numRuns, int numLines, Inventory inventory, this._getContext) : root = Node(id, _getContext) {
    _constructTree(root);

    root.numRuns = numRuns;
    root.numLines = numLines;

    // Stopwatch sw = Stopwatch();
    // sw.start();

    refreshTreeState(inventory);

    // sw.stop();
    // print(sw.elapsed);
  }

  void _constructTree(Node node) {
    if (EveStaticData.isBuildable(node.id) && !EveStaticData.isFuelBlock(node.id)) {
      final childIDs = EveStaticData.blueprints[node.id]!.inputTypeIDs;
      for (var childID in childIDs) {
        final child = Node(childID, _getContext);
        _constructTree(child);
        node.addChild(child);
      }
    }
  }

  bool setShouldBuildID(int _id, bool shouldBuild) {
    bool didChange = false;
    for (var childID in root.children.keys) {
      if (childID == _id) {
        root.children[_id]!.shouldBuild = shouldBuild;
        root.children[_id]!.bonusedChildNumNeeded.clear(); // this is not necessary I think
        didChange = true;
      }
    }
    return didChange;
  }

  void setNumRuns(int numRuns) {
    root.numRuns = numRuns;
  }

  void setNumLines(int numLines) {
    root.numLines = numLines;
  }

  int getNumRuns() {
    return root.numRuns;
  }

  int getNumLines() {
    return root.numLines;
  }

  void _clearState() {
    rootBillCache = null;
    root.bonusedChildNumNeeded.clear();
    for (var child in root.children.values) {
      child.numRuns = 0;
      child.numLines = 0;
      child.bonusedChildNumNeeded.clear();
      for (var grandChild in child.children.values) {
        grandChild.numRuns = 0;
        grandChild.numLines = 0;
        grandChild.bonusedChildNumNeeded.clear();
      }
    }
  }

  void refreshTreeState(Inventory inventory) {
    _clearState();

    // compute child num runs
    for (Node child in root.children.values) {
      if (child.shouldBuild) {
        child.numRuns = root.getChildNumRuns(child.id, inventory);
      } else {
        root.bonusedChildNumNeeded[child.id] = root.getBonusedNumChildNeeded(child.id, inventory);
      }
    }

    // compute child num lines
    List<Tuple3<int, int, int>> jobs = [];
    for (Node child in root.children.values) {
      if (child.shouldBuild && child.numRuns > 0) {
        jobs.add(Tuple3(child.numRuns, child.getBP().baseTimePerRunSeconds, child.id));
      }
    }
    var lineAllocator = LineAllocator();
    // Assumes at least 1 line per child to build
    int reactionsSkillLevel = _getContext().reactionSkillLevel;
    double structureTimeBonus = _getContext().structureTimeBonus;
    List<Tuple2<int, int>> lineAlloc = lineAllocator.allocateLines(
        root.numLines, jobs, (numRuns, baseTime) => calcBonusedTimeSeconds(numRuns, baseTime, reactionsSkillLevel, structureTimeBonus));
    for (var tuple in lineAlloc) {
      root.children[tuple.item2]!.numLines = tuple.item1;
    }

    // Check if the user has not provided enough lines for this reaction
    for (Node child in root.children.values) {
      bool shouldBuild = child.shouldBuild;
      bool buyingAllFromMarket = child.numRuns > 0;
      bool noLinesAllocated = child.numLines == 0;
      if (shouldBuild && buyingAllFromMarket && noLinesAllocated) {
        // return ErrorCode.NotEnoughLinesGivenToReaction;

        // force the build to have infinite cost/profit but put the program in a valid state
        child.numRuns = 9999999999;
        child.numLines = 1;
      }
    }

    // update bonused child num needed for grandchildren
    for (Node child in root.children.values) {
      if (child.shouldBuild && child.numRuns > 0) {
        for (var grandChildID in child.children.keys) {
          child.bonusedChildNumNeeded[grandChildID] = child.getBonusedNumChildNeeded(grandChildID, inventory);
        }
      }
    }
  }

  Map<int, int> _getBillOfMaterials(Node node) {
    final bill = <int, int>{};
    for (Node child in node.children.values) {
      if (child.shouldBuild && child.numRuns > 0) {
        combineMaps(bill, _getBillOfMaterials(child));
      } else {
        if (!bill.containsKey(child.id)) {
          bill[child.id] = 0;
        }
        bill[child.id] = bill[child.id]! + node.bonusedChildNumNeeded[child.id]!;
      }
    }
    return bill;
  }

  Map<int, int> getBillOfMaterials() {
    if (rootBillCache != null) {
      return rootBillCache!;
    }
    var bill = _getBillOfMaterials(root);
    rootBillCache = bill;
    return bill;
  }

  Map<int, int> getExcessMats() {
    Map<int, int> excess = {};
    for (Node child in root.children.values) {
      if (child.shouldBuild && child.numRuns > 0) {
        excess[child.id] = child.numRuns * child.getBP().numProducedPerRun - root.bonusedChildNumNeeded[child.id]!;
      }
    }
    return excess;
  }

  Tuple4<int, int, int, int> getTimeToBuild() {
    return secondsToDHMS(root.getTimeToBuildFullTreeSeconds());
  }

  double getTimeToBuildSeconds() {
    return root.getTimeToBuildFullTreeSeconds();
  }

  double getTotalJobInstallationCost(Map<int, double> adjustedPrices) {
    return root.getTotalJobInstallationCost(adjustedPrices);
  }

  int getNumProduced() {
    return getNumRuns() * root.getBP().numProducedPerRun;
  }

  double getProfit(Market market) {
    final numProduced = root.numRuns * root.getBP().numProducedPerRun;
    final value = market.getAvgMaxBuyForQuantity(id, numProduced) * numProduced;
    final cost = getTotalCost(market);
    return (1 - _getContext().salesTaxPercent) * value - cost;
  }

  double getTotalCost(Market market) {
    double jobInstallCost = getTotalJobInstallationCost(market.adjustedPrices);
    double materialCost = getTotalMaterialCost(market);
    return jobInstallCost + materialCost;
  }

  double getTotalMaterialCost(Market market) {
    final bill = getBillOfMaterials();
    final costs = market.getAvgMinSellForShoppingList(bill);

    final treeBill = getBillOfMaterials();
    return treeBill.entries.fold(0.0, (double s, x) => s + costs[x.key]! * x.value);
  }
}
