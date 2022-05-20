import 'package:flutter/material.dart';

import '../math.dart';
import '../misc.dart';
import '../sde.dart';
import '../sde_extra.dart';
import '../strings.dart';
import 'controllers.dart';

enum _SortColumn {
  DEFAULT,
  PROFIT,
  COST,
  PERCENT,
  COSTPERUNIT,
  SELLPERUNIT,
  OUTM3,
}

enum _SortDir {
  ASC,
  DESC,
}

class TargetsTableController with ChangeNotifier {
  final MarketController _market;
  final Build _build;
  final OptionsController _options;
  final BuildItemsController _buildItems;

  final _data = <_Data>[];
  final _focusNodes = <int, FocusNode>{};

  var _sortColumn = _SortColumn.DEFAULT;
  var _sortDir = _SortDir.DESC;

  TargetsTableController(this._market, this._build, this._buildItems, this._options, Strings strings) {
    _market.addListener(_handleModelChange);
    _build.addListener(_handleModelChange);
    strings.addListener(notifyListeners);

    _handleModelChange(notify: false);
  }

  void _handleModelChange({notify = true}) {
    _data.clear();
    final targetIds = _buildItems.getTargetsIDs();

    final bom = _build.getBOM();
    final bomCostsPerUnit = _market.avgBuyFromSell(bom);
    final bomCosts = prod(bom, bomCostsPerUnit);
    for (int tid in targetIds) {
      final runs = _buildItems.getTargetRuns(tid);
      final qty = runs * SD.numProducedPerRun(tid);
      final bomShare = _build.getCostShare(tid);
      final cost = dot(bomCosts, bomShare);
      final costPerUnit = cost / qty;
      final sellPerUnit = _market.avgSellToBuyItem(tid, qty);
      final sellValue = sellPerUnit * qty;
      final profit = (1 - _options.getSalesTaxPercent() / 100) * sellValue - cost;
      final percent = profit / cost;
      final outM3 = SD.m3(tid, qty);
      if (!_focusNodes.containsKey(tid)) {
        _focusNodes[tid] = FocusNode(debugLabel: SD.enName(tid));
      }
      _data.add(_Data(tid, runs, profit, cost, percent, costPerUnit, sellPerUnit, outM3, _focusNodes[tid]!));
    }

    _focusNodes.keys.toList().forEach((tid) {
      if (!targetIds.contains(tid)) {
        _focusNodes[tid]!.dispose();
        _focusNodes.remove(tid);
      }
    });

    _resort();

    if (notify) {
      notifyListeners();
    }
  }

  void _resort() {
    switch (_sortColumn) {
      case _SortColumn.DEFAULT:
        break;
      case _SortColumn.PROFIT:
        _data.sort((a, b) => _sortFunc(a.profit, b.profit));
        break;
      case _SortColumn.COST:
        _data.sort((a, b) => _sortFunc(a.cost, b.cost));
        break;
      case _SortColumn.PERCENT:
        _data.sort((a, b) => _sortFunc(a.percent, b.percent));
        break;
      case _SortColumn.COSTPERUNIT:
        _data.sort((a, b) => _sortFunc(a.costPerUnit, b.costPerUnit));
        break;
      case _SortColumn.SELLPERUNIT:
        _data.sort((a, b) => _sortFunc(a.sellPerUnit, b.sellPerUnit));
        break;
      case _SortColumn.OUTM3:
        _data.sort((a, b) => _sortFunc(a.outM3, b.outM3));
        break;
    }
  }

  int _sortFunc(num a, num b) {
    return _sortDir == _SortDir.ASC ? a.compareTo(b) : b.compareTo(a);
  }

  int getNumberOfItems() => _data.length;

  TargetsRowData getRowData(int listIndex) {
    _Data x = _data[listIndex];
    String name = Strings.get(SDE.items[x.tid]!.nameLocalizations);
    int runs = _buildItems.getTargetRuns(x.tid);
    String profit = currencyFormatNumber(x.profit);
    String cost = currencyFormatNumber(x.cost, removeFraction: true, roundIfOverMillion: true);
    String percent = percentFormat(x.percent);
    bool percentPositive = x.percent >= 0.0;
    String costPerUnit = currencyFormatNumber(x.costPerUnit);
    String sellPerUnit = currencyFormatNumber(x.sellPerUnit);
    String outM3 = volumeNumberFormat(x.outM3);
    FocusNode focusNode = x.focusNode;
    return TargetsRowData(
        x.tid, name, runs, profit, cost, percent, percentPositive, costPerUnit, sellPerUnit, outM3, focusNode);
  }

  void _advanceSortState(_SortColumn col) {
    if (_sortColumn == col) {
      if (_sortDir == _SortDir.DESC) {
        _sortDir = _SortDir.ASC;
      } else {
        _sortColumn = _SortColumn.DEFAULT;
        _sortDir = _SortDir.DESC;
      }
    } else {
      _sortColumn = col;
      _sortDir = _SortDir.DESC;
    }
    _handleModelChange();
  }

  void sortProfit() => _advanceSortState(_SortColumn.PROFIT);

  void sortCost() => _advanceSortState(_SortColumn.COST);

  void sortPercent() => _advanceSortState(_SortColumn.PERCENT);

  void sortCostPerUnit() => _advanceSortState(_SortColumn.COSTPERUNIT);

  void sortSellPerUnit() => _advanceSortState(_SortColumn.SELLPERUNIT);

  void sortOutM3() => _advanceSortState(_SortColumn.OUTM3);

  String exportCSV() {
    List<String> result = ['Name,Runs,Profit,Cost,Percent,Cost/Unit,Sell/Unit,OutM3'];
    for (var data in _data) {
      result.add(data.toCSVString());
    }
    return result.join('\n');
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
  final FocusNode focusNode;

  const _Data(this.tid, this.runs, this.profit, this.cost, this.percent, this.costPerUnit, this.sellPerUnit, this.outM3,
      this.focusNode);

  String toCSVString() {
    final name = Strings.get(SDE.items[tid]!.nameLocalizations);
    return [name, runs, profit, cost, percent*100, costPerUnit, sellPerUnit, outM3].map((e)=>e.toString()).join(',');
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
  final String costPerUnit;
  final String sellPerUnit;
  final String outM3;
  final FocusNode focusNode;

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
    this.focusNode,
  );
}
