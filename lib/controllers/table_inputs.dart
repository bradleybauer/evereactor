import 'package:EveIndy/misc.dart';
import 'package:flutter/material.dart';

import '../math.dart';
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

  final Map<int, _Data> _data = {};

  InputsTableController(this._market, this._build, Strings strings) {
    _market.addListener(_handleModelChange);
    _build.addListener(_handleModelChange);
    strings.addListener(() {
      notifyListeners();
    });
  }

  void _handleModelChange({notify = true}) {
    _data.clear();

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
    final bom = _build.getBOM();
    final bomCostsPerUnit = _market.avgBuyFromSell(bom);
    final bomCosts = prod(bom, bomCostsPerUnit);
    for (int tid in bomCosts.keys) {
      _data[tid] = _Data(bomCosts[tid]!, bomCostsPerUnit[tid]!);
    }

    _sortedIds = _inputIds; // TODO temporary
    if (notify) {
      notifyListeners();
    }
  }

  int getNumberOfItems() => _inputIds.length;

  InputsRowData getRowData(int listIndex) {
    int tid = _sortedIds[listIndex];
    _Data x = _data[tid]!;
    final name = Strings.get(SDE.items[tid]!.nameLocalizations);
    final totalCost = currencyFormatNumber(x.totalCost);
    final costPerUnit = currencyFormatNumber(x.costPerUnit,
        roundBigIskToMillions: false, roundFraction: false, removeFraction: false, removeZeroFractionFromString: true);
    return InputsRowData(name, totalCost, costPerUnit);
  }
}

class _Data {
  final double totalCost;
  final double costPerUnit;

  const _Data(this.totalCost, this.costPerUnit);
}

class InputsRowData {
  final String name;
  final String totalCost;
  final String costPerUnit;

  const InputsRowData(this.name, this.totalCost, this.costPerUnit);
}
