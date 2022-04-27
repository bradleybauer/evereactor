import 'package:flutter/material.dart';

import '../controllers/options.dart';
import '../controllers/build_items.dart';
import '../math.dart';
import '../misc.dart';
import '../sde.dart';
import '../sde_extra.dart';
import '../strings.dart';
import 'build.dart';
import 'market.dart';

class TargetsTableController with ChangeNotifier {
  final BuildItemsController _buildItems;
  final MarketController _market;
  final Build _build;
  final OptionsController _options;

  List<int> _targetsIds = [];
  List<int> _sortedIds = [];

  final Map<int,_Data> _data = {};

  TargetsTableController(this._market, this._build, this._buildItems, this._options, Strings strings) {
    _market.addListener(_handleModelChange);
    _build.addListener(_handleModelChange);
    _options.addListener(_handleModelChange);
    strings.addListener(notifyListeners);

    _handleModelChange(notify: false);
  }

  void _handleModelChange({notify = true}) {
    _data.clear();

    _targetsIds = _buildItems.getTargetsIds();
    final bom = _build.getBOM();
    final bomCostsPerUnit = _market.avgBuyFromSell(bom);
    final bomCosts = prod(bom, bomCostsPerUnit);
    for (int tid in _targetsIds){
      final runs = _buildItems.getTargetRuns(tid);
      final qty = runs * SD.numProducedPerRun(tid);
      final bomShare = _build.getCostShare(tid);
      final cost = dot(bomCosts,bomShare);
      final costPerUnit = cost / qty;
      final sellValue = _market.avgSellToBuyItem(tid, qty) * qty;
      final sellPerUnit = sellValue / qty;
      final profit = (1-_options.getSalesTaxPercent()/100)*sellValue-cost;
      final percent = profit / cost;
      final outM3 = SD.m3(tid, qty);
      _data[tid]=_Data(tid, runs, profit, cost, percent, costPerUnit, sellPerUnit, outM3);
    }

    _sortedIds = _targetsIds; // TODO temporary
    if (notify) {
      notifyListeners();
    }
  }

  int getNumberOfItems() => _buildItems.getNumberOfTargets();

  TargetsRowData getRowData(int listIndex) {
    int tid = _sortedIds[listIndex];
    _Data x = _data[tid]!;
    String name = Strings.get(SDE.items[tid]!.nameLocalizations);
    int runs = _buildItems.getTargetRuns(tid);
    String profit = currencyFormatNumber(x.profit);
    String cost = currencyFormatNumber(x.cost);
    String percent = percentFormat(x.percent);
    bool percentPositive = x.percent>=0.0;
    String costPerUnit = currencyFormatNumber(x.costPerUnit,removeFraction: false, roundFraction: false, roundBigIskToMillions: false);
    String sellPerUnit = currencyFormatNumber(x.sellPerUnit,removeFraction: false,roundFraction: false);
    String outM3 = volumeNumberFormat(x.outM3);
    return TargetsRowData(tid, name, runs, profit, cost, percent, percentPositive, costPerUnit, sellPerUnit, outM3);

  }
}

class _Data {
  final int tid;
  final int runs;
  final double profit;
  final double cost;
  final double percent;
  final double costPerUnit;
  final double sellPerUnit;
  final double outM3;

  const _Data(this.tid, this.runs, this.profit, this.cost, this.percent, this.costPerUnit, this.sellPerUnit, this.outM3);
}

class TargetsRowData {
  final int tid;
  final String name;
  final int runs;
  final String profit;
  final String cost;
  final String percent;
  final bool percentPositive;
  final String costPerUnit;
  final String sellPerUnit;
  final String outM3;

  const TargetsRowData(
    this.tid,
    this.name,
    this.runs,
    this.profit,
    this.cost,
    this.percent,
    this.percentPositive,
    this.costPerUnit,
    this.sellPerUnit,
    this.outM3,
  );
}
