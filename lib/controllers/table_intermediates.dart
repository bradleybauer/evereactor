import 'package:flutter/material.dart';

import '../math.dart';
import '../misc.dart';
import '../sde.dart';
import '../sde_extra.dart';
import '../strings.dart';
import 'basic_build.dart';
import 'build_items.dart';
import 'market.dart';
import 'options.dart';

class IntermediatesTableController with ChangeNotifier {
  final MarketController _market;
  final BuildItemsController _buildItems;
  final OptionsController _options;
  final BasicBuild _basicBuild;

  final _data = <_Data>[];

  IntermediatesTableController(this._market, this._buildItems, this._options, this._basicBuild, Strings strings) {
    _market.addListener(_handleModelChanged);
    _basicBuild.addListener(_handleModelChanged);
    strings.addListener(() {
      notifyListeners();
    });
  }

  void _handleModelChanged() {
    _data.clear();

    final target2runs = _buildItems.getTarget2RunsCopy();
    double totalSellValue = target2runs.entries.fold(0.0, (double p, e) {
      final tid = e.key;
      final runs = e.value;
      final qty = SD.numProducedPerRun(tid) * runs;
      return p + _market.avgSellToBuyItem(tid, qty) * qty;
    });
    totalSellValue *= (1 - _options.getSalesTaxPercent() / 100);
    final bom = _basicBuild.getBOM(target2runs);
    final profitWithCurrentSettings = totalSellValue - getCost(bom);

    final intermediateIds = _buildItems.getItemsWithBuildBuyOptions().toList(growable: false);
    for (int tid in intermediateIds) {
      final toggleBom = _basicBuild.getBOM(target2runs, toggleTid: tid);
      final profitWithOpposite = totalSellValue - getCost(toggleBom);
      double value = profitWithCurrentSettings - profitWithOpposite;
      if (!_buildItems.getShouldBuild(tid)) {
        value *= -1;
      }
      _data.add(_Data(tid, value));
    }

    // TODO make this not suck
    //      if a,b have a common ancestor A then a < b iff c_a < c_b where c_i is a direct child of A. Direct children of A are ordered by name.
    //      else a < b iff root_a < root_b where roots are ordered by name.
    //
    //      i think that is the same as a<b iff uc_a<uc_b where uc's are the highest uncommon ancestors of a,b
    _data.sort((a, b) {
      if (materials(a.tid).contains(b.tid)) {
        return -1;
      }
      if (materials(b.tid).contains(a.tid)) {
        return 1;
      }
      return 0;
      // int comp = a.value.sign.compareTo(b.value.sign);
      // if (comp == 0 && materials(a.tid).contains(b.tid)) {
      //   comp = -1;
      // }
      // if (comp == 0) {
      //   comp = SD.enName(a.tid).compareTo(SD.enName(b.tid));
      // }
      // return comp;
    });

    notifyListeners();
  }

  Set<int> materials(int pid) {
    final result = <int>{};
    for (int cid in SD.materials(pid).keys) {
      result.add(cid);
      if (!SD.isWrongIndyType(pid, cid) && SD.isBuildable(cid)) {
        result.addAll(materials(cid));
      }
    }
    return result;
  }

  double getCost(Map<int, int> bom) {
    final bomCostsPerUnit = _market.avgBuyFromSell(bom);
    final bomCosts = prod(bom, bomCostsPerUnit);
    return bomCosts.values.fold(0.0, (double p, e) => p + e);
  }

  int getNumberOfItems() => _data.length;

  IntermediatesRowData getRowData(int listIndex) {
    final x = _data[listIndex];
    final name = Strings.get(SDE.items[x.tid]!.nameLocalizations);
    final value = currencyFormatNumber(x.value);
    final valuePositive = x.value > 0;
    return IntermediatesRowData(x.tid, name, value, valuePositive);
  }

  String exportCSV() {
    if (_data.isEmpty) {
      return "";
    }
    List<String> result = ['Name,Build Value'];
    for (var data in _data) {
      result.add(data.toCSVString());
    }
    return result.join('\n');
  }
}

class _Data {
  final int tid;
  final double value;

  _Data(this.tid, this.value);

  String toCSVString() {
    final name = Strings.get(SDE.items[tid]!.nameLocalizations);
    return name + ',' + value.toString();
  }
}

class IntermediatesRowData {
  final int tid;

  final String name;
  final String value;
  final bool valuePositive;

  const IntermediatesRowData(this.tid, this.name, this.value, this.valuePositive);
}
