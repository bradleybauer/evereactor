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

    // To help reduce by amount that items jump around when clicked
    _data.sort((a, b) {
      int comp = a.value.sign.compareTo(b.value.sign);
      if (comp == 0 && materials(a.tid).contains(b.tid)) {
        comp = -1;
      }
      if (comp == 0 && materials(b.tid).contains(a.tid)) {
        comp = 1;
      }
      // if (comp == 0) {
      //   comp = SD.enName(a.tid).compareTo(SD.enName(b.tid));
      // }
      return comp;
    });
    // _data.sort((a, b) => a.value.compareTo(b.value));
    // TODO sort data

    notifyListeners();
  }

  Set<int> materials(int pid) {
    final result = <int>{};
    for (int cid in SD.materials(pid).keys) {
      if (!SD.isWrongIndyType(pid, cid) && SD.isBuildable(cid)) {
        result.add(cid);
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
}

class _Data {
  final int tid;
  final double value;

  _Data(this.tid, this.value);
}

class IntermediatesRowData {
  final int tid;

  final String name;
  final String value;
  final bool valuePositive;

  const IntermediatesRowData(this.tid, this.name, this.value, this.valuePositive);
}