import 'package:flutter/material.dart';

import '../controllers/build_items.dart';
import '../sde.dart';
import '../strings.dart';
import 'build.dart';
import 'market.dart';

class TargetsTableController with ChangeNotifier {
  final BuildItemsController _buildItems;
  final MarketController _market;
  final Build _build;

  List<int> _targetsIds = [];
  List<int> _sortedIds = [];

  TargetsTableController(this._market, this._build, this._buildItems, Strings strings) {
    _market.addListener(() {
      notifyListeners();
    });

    _build.addListener(() {
      _targetsIds = _buildItems.getTargetsIds();
      // TODO temporary
      _sortedIds = _targetsIds;
      notifyListeners();
    });

    strings.addListener(() {
      notifyListeners();
    });
  }

  int getNumberOfItems() => _buildItems.getNumberOfTargets();

  int getTid(int index) => _sortedIds[index];

  TargetsRowData getRowData(int listIndex) {
    int tid = _sortedIds[listIndex];
    String name = Strings.get(SDE.items[tid]!.nameLocalizations);
    int runs = _buildItems.getTargetRuns(tid);
    String profit = "0m";
    String cost = "0m";
    String percent = "0%";
    bool percentPositive = true;
    String cost_per_unit = "0";
    String sell_per_unit = "0";
    String out_m3 = "1";
    return TargetsRowData(tid, name, runs, profit, cost, percent, percentPositive, cost_per_unit, sell_per_unit, out_m3);
  }
}

class TargetsRowData {
  final int tid;
  final String name;
  final int runs;
  final String profit;
  final String cost;
  final String percent;
  final bool percentPositive;
  final String cost_per_unit;
  final String sell_per_unit;
  final String out_m3;

  const TargetsRowData(
    this.tid,
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
