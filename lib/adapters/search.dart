import 'package:flutter/material.dart';

import '../sde.dart';
import '../search.dart';
import '../strings.dart';
import 'build_items.dart';

class SearchAdapter with ChangeNotifier {
  final BuildItemsAdapter _buildItems; // for adding items to the build
  //final MarketAdapter market;
  //final BasicBuild // for calculating profit percentages fast
  //final CacheAdapter

  final _search = FilterSearch();
  static final _ids = SDE.blueprints.keys.toList(growable: false);
  List<int> _sortedIds = _ids;
  final List<List<String>> _searchCandidates = [];

  SearchAdapter(this._buildItems, Strings strings) {
    _initSearchCandidates();

    strings.addListener(() {
      notifyListeners();
      _initSearchCandidates();
    });
  }

  void _initSearchCandidates() {
    for (int id in _ids) {
      final String name = Strings.get(SDE.items[id]!.nameLocalizations);
      _searchCandidates.add([name] + _getCategoryNames(id));
    }
  }

  // Get the names of the item's market category (and parent market categories) in the current localization.
  List<String> _getCategoryNames(int id) {
    return SDE.buildableItem2marketGroupAncestors[id]!.map((int marketGroupID) {
      return Strings.get(SDE.marketGroupNames[marketGroupID]!);
    }).toList(growable: false);
  }

  void addToBuild(int listIndex) => _buildItems.add(_sortedIds[listIndex], 1);

  void setSearchText(String text) {
    if (text != '') {
      _sortedIds = _search.search(text, _searchCandidates).map((i) => _ids[i]).toList(growable: false);
    } else {
      _sortedIds = _ids;
    }
    notifyListeners();
  }

  int getNumberOfSearchResults() => _sortedIds.length;

  SearchTableRowData getRowData(int listIndex) {
    final id = _sortedIds[listIndex];
    final name = Strings.get(SDE.items[id]!.nameLocalizations);
    final percent = '';
    final percentPositive = true;
    final category = _getCategoryNames(id).join(' > ');
    return SearchTableRowData(name, percent, percentPositive, category);
  }
}

class SearchTableRowData {
  final String name;
  final String percent;
  final bool percentPositive;
  final String category;

  const SearchTableRowData(this.name, this.percent, this.percentPositive, this.category);
}

// needs access to very basic profit calculation
//  getProfit(tid)
//    SimpleBuild
//       BuildOptions
//         maybe uses this
//       BuildItemOptions
//         maybe uses this
//       build env
//         everything on one line
//         try to use current build options?
//         super basic dependency calculations
//    Market
