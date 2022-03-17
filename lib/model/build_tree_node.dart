import 'dart:math';
import 'context.dart';
import 'inventory.dart';
import 'util.dart';
import 'eve_static_data.dart';
import 'blueprint.dart';

class Node {
  final EveBuildContext Function() ctxProvider;
  final Map<int, Node> children = {};
  // The amount of each child needed after using the inventory
  final Map<int, int> bonusedChildNumNeeded = {};
  final int id;

  bool shouldBuild;
  int numRuns = 0;
  int numLines = 0;

  Node(this.id, this.ctxProvider) : shouldBuild = EveStaticData.isBuildable(id) && !EveStaticData.isFuelBlock(id);

  bool _isLeafNode() {
    return children.isEmpty;
  }

  Blueprint getBP() {
    // this function cannot be called on leaf nodes
    assert(!_isLeafNode());
    return EveStaticData.blueprints[id]!;
  }

  void addChild(Node child) {
    children[child.id] = child;
  }

  // num required for child depends on how numRuns are spread accross numLines
  int getBonusedNumChildNeeded(int childID, Inventory inventory) {
    int childBaseNumPerRunNeeded = getBP().getBaseNumChildNeeded(childID);
    int n = (numRuns / numLines).floor();
    int m = numRuns % numLines;
    int x = calcBonusedMaterialAmount(n, childBaseNumPerRunNeeded, ctxProvider());
    int y = calcBonusedMaterialAmount(n + 1, childBaseNumPerRunNeeded, ctxProvider());
    int quantity = (numLines - m) * x + m * y;
    int quantityNotSuppliedByInventory = inventory.useQuantity(childID, quantity);
    return quantityNotSuppliedByInventory;
  }

  int getChildNumRuns(int childID, Inventory inventory) {
    bonusedChildNumNeeded[childID] = getBonusedNumChildNeeded(childID, inventory);
    return (bonusedChildNumNeeded[childID]! / EveStaticData.blueprints[childID]!.numProducedPerRun).ceil();
  }

  double getTimeToBuildNodeSeconds() {
    return calcBonusedTimeSeconds(getMaxNumRunsPerLine(numRuns, numLines), getBP().baseTimePerRunSeconds, ctxProvider().reactionSkillLevel,
        ctxProvider().structureTimeBonus);
  }

  double getTimeToBuildFullTreeSeconds() {
    if (!shouldBuild) {
      return 0;
    }
    double time = getTimeToBuildNodeSeconds();
    double maxChildTime = children.values.fold(0.0, (double m, c) => max(m, c.getTimeToBuildFullTreeSeconds()));
    return time + maxChildTime;
  }

  double _getTotalJobInstallationCost(Node node, Map<int, double> adjustedPrices) {
    // cost to build me
    double baseCosts = 0.0;
    for (var child in node.children.values) {
      final baseNumChildNeededPerRun = node.getBP().getBaseNumChildNeeded(child.id);
      baseCosts += baseNumChildNeededPerRun * adjustedPrices[child.id]!;
    }
    final runsPerLine = (node.numRuns / node.numLines).floor();
    final numLinesWithExtraRun = node.numRuns % node.numLines;
    final x = (node.numLines - numLinesWithExtraRun) * runsPerLine * baseCosts;
    final y = numLinesWithExtraRun * (runsPerLine + 1) * baseCosts;
    double cost = (x + y) * ctxProvider().systemCostIndex;
    // plus cost to build children
    for (var child in node.children.values) {
      if (child.shouldBuild && child.numRuns > 0) {
        cost += _getTotalJobInstallationCost(child, adjustedPrices);
      }
    }
    return cost;
  }

  double getTotalJobInstallationCost(Map<int, double> adjustedPrices) {
    return _getTotalJobInstallationCost(this, adjustedPrices);
  }
}
