import 'dart:math';

import 'package:EveIndy/math.dart';
import 'package:EveIndy/misc.dart';
import 'package:flutter/material.dart';

import '../sde.dart';
import '../sde_extra.dart';
import '../search.dart';
import '../strings.dart';
import 'controllers.dart';

enum _SortDir {
  DEFAULT,
  ASC,
  DESC,
}

class SearchController with ChangeNotifier {
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

  var _sortDir = _SortDir.DESC;

  SearchController(this._market, this._buildItems, this._basicBuild, this._options, Strings strings) {
    _initSearchCandidates();

    _basicBuild.addListener(_handleChange);
    _market.addListener(_handleChange);

    strings.addListener(() {
      notifyListeners();
      _initSearchCandidates();
    });

    _handleChange();
  }

  void _handleChange() {
    _data.clear();

    // update profits
    for (int tid in _filteredIds) {
      final halfVolume = _market.halfBuyVolume(tid);
      final unitPrice = _market.avgSellToBuyItem(tid, halfVolume);
      if (unitPrice >= 1) {
        final approximateRuns = min(100000, ceilDiv(200000000, SD.numProducedPerRun(tid)*unitPrice.ceil()));
        final numProduced = min(halfVolume, SD.numProducedPerRun(tid) * approximateRuns);
        int runs = ceilDiv(numProduced, SD.numProducedPerRun(tid));

        final totalSellValue =
            (1 - _options.getSalesTaxPercent() / 100) * numProduced * _market.avgSellToBuyItem(tid, numProduced);
        final bom = _basicBuild.getBOM({tid: runs}, useBuildItems: false);
        final cost = getCost(bom);
        final profit = totalSellValue - cost;
        double percent = profit / cost;
        if ((!SD.isTech2(tid) && !SD.isTech1(tid)) || percent > 10 || !percent.isFinite || percent <= .009) {
          if (SD.enName(tid).contains('Photonic Metamaterials'))
            print('photonic:' + profit.toString());
          percent = double.negativeInfinity;
          runs = 1;
        }
        _data.add(_Data(tid, percent, runs));
      } else {
        _data.add(_Data(tid, double.negativeInfinity, 1));
      }
    }

    if (_sortDir == _SortDir.ASC) {
      _data.sort((a, b) => a.percent.compareTo(b.percent));
    } else if (_sortDir == _SortDir.DESC) {
      _data.sort((a, b) => b.percent.compareTo(a.percent));
    }

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
    _handleChange();
  }

  int getNumberOfSearchResults() => _data.length;

  SearchTableRowData getRowData(int listIndex) {
    final x = _data[listIndex];
    final name = Strings.get(SDE.items[x.tid]!.nameLocalizations);
    final percent = x.percent.isFinite ? percentFormat(x.percent) : '';
    final percentPositive = x.percent.isFinite ? x.percent > 0 : false;
    final category = _getCategoryNames(x.tid).join(' > ');
    return SearchTableRowData(name, percent, percentPositive, category);
  }

  void advSortDir() {
    if (_sortDir == _SortDir.ASC) {
      _sortDir = _SortDir.DESC;
    } else if (_sortDir == _SortDir.DESC) {
      _sortDir = _SortDir.DEFAULT;
    } else {
      _sortDir = _SortDir.ASC;
    }
    _handleChange();
  }
}

class _Data {
  final int tid;
  final double percent;
  final int runs;

  const _Data(this.tid, this.percent, this.runs);
}

class SearchTableRowData {
  final String name;
  final String percent;
  final bool percentPositive;
  final String category;

  const SearchTableRowData(this.name, this.percent, this.percentPositive, this.category);
}
