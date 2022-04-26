import 'package:flutter/material.dart';

import '../sde.dart';
import '../sde_extra.dart';
import '../strings.dart';
import 'build.dart';
import 'market.dart';

class IntermediatesTableAdapter with ChangeNotifier {
  final MarketAdapter _market;
  final Build _build;

  List<int> _intermediatesIds = [];
  List<int> _sortedIds = [];

  IntermediatesTableAdapter(this._market, this._build, Strings strings) {
    _market.addListener(() {
      notifyListeners();
    });

    _build.addListener(() {
      _intermediatesIds = _build.getIntermediatesIds()
        ..sort((a, b) {
          String a_cat = SDE.item2marketGroupAncestors[a]!.map((int marketGroupID) {
            return SDE.marketGroupNames[marketGroupID]!['en'];
          }).take(3).join('');
          String b_cat = SDE.item2marketGroupAncestors[b]!.map((int marketGroupID) {
            return SDE.marketGroupNames[marketGroupID]!['en'];
          }).take(3).join('');
          int comp = b_cat.compareTo(a_cat);
          if (comp == 0) {
            return SD.enName(a).compareTo(SD.enName(b));
          }
          return comp;
        });
      // TODO temporary
      _sortedIds = _intermediatesIds;
      notifyListeners();
    });

    strings.addListener(() {
      notifyListeners();
    });
  }

  int getNumberOfItems() => _intermediatesIds.length;

  int getTid(int index) => _sortedIds[index];

  IntermediatesRowData getRowData(int listIndex) {
    int tid = _sortedIds[listIndex];
    final name = Strings.get(SDE.items[tid]!.nameLocalizations);
    final value = "0m";
    final valuePositive = true;
    return IntermediatesRowData(name, value, valuePositive);
  }
}

class IntermediatesRowData {
  final String name;
  final String value;
  final bool valuePositive;

  const IntermediatesRowData(
    this.name,
    this.value,
    this.valuePositive,
  );
}
