import 'package:EveIndy/math.dart';
import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';

import '../industry.dart';
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

  Map<int, int> getBOM(Map<int, int> runs, {int toggleTid = -1}) {
    final bom = <int, int>{};
    while (runs.isNotEmpty) {
      var next = <int, int>{};
      var numNeededForEachChild = <int, int>{};
      runs.forEach((tid, runs) {
        final bonus = getMaterialBonusMemoized(tid, _options, _buildItems, materialEfficiencyMemo);
        SD.materials(tid).forEach((cid, qtyPerRun) {
          final numNeeded = getNumNeeded(runs, 1, qtyPerRun, bonus);
          if (!SD.isWrongIndyType(tid, cid) &&
              SD.isBuildable(cid) &&
              (cid == toggleTid ? !_buildItems.getShouldBuild(cid) : _buildItems.getShouldBuild(cid))) {
            numNeededForEachChild.update(cid, (value) => value + numNeeded, ifAbsent: () => numNeeded);
          } else {
            bom.update(cid, (value) => value + numNeeded, ifAbsent: () => numNeeded);
          }
        });
      });
      numNeededForEachChild.forEach((cid, numNeeded) {
        next[cid] = ceilDiv(numNeeded, SD.numProducedPerRun(cid));
      });
      runs = next;
    }
    return bom;
  }
}
