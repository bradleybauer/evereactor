import 'dart:math';

import 'package:eve_reactor/math.dart';
import 'package:eve_reactor/misc.dart';
import 'package:flutter/material.dart';

import '../sde.dart';
import '../sde_extra.dart';
import '../search.dart';
import '../strings.dart';
import 'controllers.dart';

enum _SortDir {
  ASC,
  DESC,
}

enum _SortColumn {
  DEFAULT,
  IPH,
  PROFIT,
}

class MySearchController with ChangeNotifier {
  final BuildItemsController _buildItems; // for adding items to the build
  final MarketController _market;
  final OptionsController _options;
  final BasicBuild _basicBuild; // for calculating profit percentages fast
  //final CacheController

  final _search = FilterSearch();
  final List<List<String>> _searchCandidates = [];

  static final _ids = SDE.blueprints.keys.toList(growable: false);

  List<int> _filteredIds = _ids;
  final _data = <_Data>[];

  var _sortColumn = _SortColumn.DEFAULT;
  var _sortDir = _SortDir.DESC;

  MySearchController(this._market, this._buildItems, this._basicBuild, this._options, Strings strings) {
    _initSearchCandidates();

    _basicBuild.addListener(_handleModelChange);
    _market.addListener(_handleModelChange);

    strings.addListener(() {
      notifyListeners();
      _initSearchCandidates();
    });

    _handleModelChange();
  }

  void _handleModelChange() {
    _data.clear();

    // update profits
    for (int tid in _filteredIds) {
      final volume = _market.buyVolume25Percent(tid);
      final unitPrice = _market.avgSellToBuyItem(tid, volume);
      if (unitPrice >= 1) {
        final approximateRuns = min(100000, ceilDiv(200000000, SD.numProducedPerRun(tid) * unitPrice.ceil()));
        final numProduced = min(volume, SD.numProducedPerRun(tid) * approximateRuns);
        int runs = ceilDiv(numProduced, SD.numProducedPerRun(tid));

        final totalSellValue = (1 - _options.getSalesTaxPercent() / 100) * numProduced * _market.avgSellToBuyItem(tid, numProduced);
        final bom = _basicBuild.getBOM({tid: runs}, useBuildItems: false);
        final cost = getCost(bom);
        final profit = totalSellValue - cost;
        final totalMachineTime = _basicBuild.getMachineTime({tid: runs}, useBuildItems: false);
        final approxTime = totalMachineTime / _options.getReactionSlots();
        double iph = profit / (approxTime / 3600);
        double percent = profit / cost;
        if ((!SD.isTech2(tid) && !SD.isTech1(tid)) || percent > 10 || !percent.isFinite || percent <= .009) {
          percent = double.negativeInfinity;
          iph = double.negativeInfinity;
          runs = 1;
        }
        _data.add(_Data(tid, percent, iph, runs));
      } else {
        _data.add(_Data(tid, double.negativeInfinity, double.negativeInfinity, 1));
      }
    }

    _resort();

    notifyListeners();
  }

  double getCost(Map<int, int> bom) {
    final bomCostsPerUnit = _market.avgBuyFromSell(bom);
    final bomCosts = prod(bom, bomCostsPerUnit);
    return bomCosts.values.fold(0.0, (double p, e) => p + e);
  }

  void _initSearchCandidates() {
    _searchCandidates.clear();
    for (int id in _ids) {
      final String name = Strings.get(SDE.items[id]!.nameLocalizations);
      _searchCandidates.add([name] + _getCategoryNames(id));
    }
  }

  // Get the names of the item's market category (and parent market categories) in the current localization.
  List<String> _getCategoryNames(int id) {
    return SDE.item2marketGroupAncestors[id]!.map((int marketGroupID) {
      return Strings.get(SDE.marketGroupNames[marketGroupID]!);
    }).toList(growable: false);
  }

  void addToBuild(int listIndex) => _buildItems.addTarget(_data[listIndex].tid, _data[listIndex].runs);

  void setSearchText(String text) {
    if (text != '') {
      _filteredIds = _search.search(text, _searchCandidates).map((i) => _ids[i]).toList(growable: false);
    } else {
      _filteredIds = _ids;
    }
    _handleModelChange();
  }

  int getNumberOfSearchResults() => _data.length;

  SearchTableRowData getRowData(int listIndex) {
    final x = _data[listIndex];
    final name = Strings.get(SDE.items[x.tid]!.nameLocalizations);
    final percent = x.percent.isFinite ? percentFormat(x.percent) : '';
    final percentPositive = x.percent.isFinite ? x.percent > 0 : false;
    final iph = x.iph.isFinite ? currencyFormatNumber(x.iph) : '';
    final category = _getCategoryNames(x.tid).join(' > ');
    return SearchTableRowData(name, percent, percentPositive, iph, category);
  }

  void _resort() {
    switch (_sortColumn) {
      case _SortColumn.DEFAULT:
        _data.sort((a, b) => _sortFunc(a.percent, b.percent));
        break;
      case _SortColumn.IPH:
        _data.sort((a, b) => _sortFunc(a.iph, b.iph));
        break;
      case _SortColumn.PROFIT:
        _data.sort((a, b) => _sortFunc(a.percent, b.percent));
        break;
    }
  }

  int _sortFunc(num a, num b) {
    return _sortDir == _SortDir.ASC ? a.compareTo(b) : b.compareTo(a);
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

  void sortIPH() => _advanceSortState(_SortColumn.IPH);
}

class _Data {
  final int tid;
  final double percent;
  final double iph;
  final int runs;

  const _Data(this.tid, this.percent, this.iph, this.runs);
}

class SearchTableRowData {
  final String name;
  final String percent;
  final String iph;
  final bool percentPositive;
  final String category;

  const SearchTableRowData(this.name, this.percent, this.percentPositive, this.iph, this.category);
}
