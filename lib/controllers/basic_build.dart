import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';

import '../industry.dart';
import '../math.dart';
import '../sde_extra.dart';
import 'build_items.dart';
import 'options.dart';

class BasicBuild with ChangeNotifier {
  final BuildItemsController _buildItems;
  final OptionsController _options;

  final materialEfficiencyMemo = <int, Fraction>{};

  BasicBuild(this._options, this._buildItems) {
    _buildItems.addListener(_handleModelChanged);
    _options.addListener(_handleModelChanged);
  }

  void _handleModelChanged() {
    materialEfficiencyMemo.clear();
    notifyListeners();
  }

  Map<int, int> getBOM(Map<int, int> items, {int toggleTid = -1, bool useBuildItems = true}) {
    final bom = <int, int>{};
    while (items.isNotEmpty) {
      var next = <int, int>{};
      var numNeededForEachChild = <int, int>{};
      items.forEach((tid, runs) {
        final bonus = getMaterialBonusMemoized(tid, _options, _buildItems, materialEfficiencyMemo);
        SD.materials(tid).forEach((cid, qtyPerRun) {
          final numNeeded = getNumNeeded(runs, 1, qtyPerRun, bonus);
          if (!SD.isWrongIndyType(tid, cid) &&
              SD.isBuildable(cid) &&
              (!useBuildItems ||
                  (cid == toggleTid ? !_buildItems.getShouldBuild(cid) : _buildItems.getShouldBuild(cid)))) {
            numNeededForEachChild.update(cid, (value) => value + numNeeded, ifAbsent: () => numNeeded);
          } else {
            bom.update(cid, (value) => value + numNeeded, ifAbsent: () => numNeeded);
          }
        });
      });
      numNeededForEachChild.forEach((cid, numNeeded) {
        next[cid] = ceilDiv(numNeeded, SD.numProducedPerRun(cid));
      });
      items = next;
    }
    return bom;
  }
}
