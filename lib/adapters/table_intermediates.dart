import 'package:flutter/material.dart';

import '../sde.dart';
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
        ..sort((a, b) { // Not a perfect sorting function
          int initial = SDE.items[a]!.marketGroupID.compareTo(SDE.items[b]!.marketGroupID);
          return initial == 0 ? a.compareTo(b) : initial;
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
