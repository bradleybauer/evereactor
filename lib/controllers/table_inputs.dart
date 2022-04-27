import 'package:flutter/material.dart';

import '../sde.dart';
import '../sde_extra.dart';
import '../strings.dart';
import 'build.dart';
import 'market.dart';

class InputsTableController with ChangeNotifier {
  final MarketController _market;
  final Build _build;

  List<int> _inputIds = [];
  List<int> _sortedIds = [];

  InputsTableController(this._market, this._build, Strings strings) {
    _market.addListener(() {
      notifyListeners();
    });

    _build.addListener(() {
      _inputIds = _build.getInputIds()
        ..sort((a, b) {
          // Could write a List compare alg here but... this works,is already written and is easy...
          String a_cat = SDE.item2marketGroupAncestors[a]!.map((int marketGroupID) {
            return SDE.marketGroupNames[marketGroupID]!['en'];
          }).join('');
          String b_cat = SDE.item2marketGroupAncestors[b]!.map((int marketGroupID) {
            return SDE.marketGroupNames[marketGroupID]!['en'];
          }).join('');
          int comp = b_cat.compareTo(a_cat);
          if (comp == 0) {
            return SD.enName(a).compareTo(SD.enName(b));
          }
          return comp;
        });
      // TODO temporary
      _sortedIds = _inputIds;
      notifyListeners();
    });

    strings.addListener(() {
      notifyListeners();
    });
  }

  int getNumberOfItems() => _inputIds.length;

  InputsRowData getRowData(int listIndex) {
    int tid = _sortedIds[listIndex];
    final name = Strings.get(SDE.items[tid]!.nameLocalizations);
    return InputsRowData(name, "0m", "0m");
  }
}

class InputsRowData {
  final String name;
  final String totalCost;
  final String costPerUnit;
  const InputsRowData(this.name, this.totalCost, this.costPerUnit);
}
