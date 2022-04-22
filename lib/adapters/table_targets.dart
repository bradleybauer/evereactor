import 'package:flutter/material.dart';

import '../adapters/build_items.dart';
import '../sde.dart';
import '../strings.dart';
import 'build.dart';
import 'market.dart';

class TargetsTableAdapter with ChangeNotifier {
  final BuildItemsAdapter _buildItems;
  final MarketAdapter _market;
  final Build _build;

  List<int> _targetsIds = [];
  List<int> _sortedIds = [];

  TargetsTableAdapter(this._market, this._build, this._buildItems, Strings strings) {
    _buildItems.addListener(() {
      _targetsIds = _buildItems.getTargetsIds();
      // TODO temporary
      _sortedIds = _targetsIds;
    });

    _market.addListener(() {
      notifyListeners();
    });

    _build.addListener(() {
      notifyListeners();
    });

    strings.addListener(() {
      notifyListeners();
    });
  }

  int getNumberOfItems() => _buildItems.getNumberOfTargets();

  TargetsTableRowData getRowData(int listIndex) {
    int id = _sortedIds[listIndex];
    String name = Strings.get(SDE.items[id]!.nameLocalizations);
    int runs = _buildItems.getTargetRuns(id) ?? 0;
    String profit = "0m";
    String cost = "0m";
    String percent = "0%";
    bool percentPositive = true;
    String cost_per_unit = "0";
    String sell_per_unit = "0";
    String out_m3 = "1";
    return TargetsTableRowData(
        name, runs, profit, cost, percent, percentPositive, cost_per_unit, sell_per_unit, out_m3);
  }

  void remove(int listIndex) => _buildItems.remove(_sortedIds[listIndex]);

  void setRuns(int listIndex, int runs) => _buildItems.setRuns(_sortedIds[listIndex], runs);
}

class TargetsTableRowData {
  final String name;
  final int runs;
  final String profit;
  final String cost;
  final String percent;
  final bool percentPositive;
  final String cost_per_unit;
  final String sell_per_unit;
  final String out_m3;

  const TargetsTableRowData(
    this.name,
    this.runs,
    this.profit,
    this.cost,
    this.percent,
    this.percentPositive,
    this.cost_per_unit,
    this.sell_per_unit,
    this.out_m3,
  );
}
