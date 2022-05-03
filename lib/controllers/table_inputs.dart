import 'package:flutter/material.dart';

import '../math.dart';
import '../misc.dart';
import '../sde.dart';
import '../sde_extra.dart';
import '../strings.dart';
import 'build.dart';
import 'market.dart';

class InputsTableController with ChangeNotifier {
  final MarketController _market;
  final Build _build;

  final _data = <_Data>[];

  InputsTableController(this._market, this._build, Strings strings) {
    _market.addListener(_handleModelChange);
    _build.addListener(_handleModelChange);
    strings.addListener(() {
      notifyListeners();
    });
  }

  void _handleModelChange({notify = true}) {
    _data.clear();

    final inputIds = _build.getInputIds()
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
    for (int tid in inputIds) {
      _data.add(_Data(tid, bomCosts[tid]!, bomCostsPerUnit[tid]!));
    }

    // TODO sort the data
    _data.sort((a, b) => b.totalCost.compareTo(a.totalCost));

    if (notify) {
      notifyListeners();
    }
  }

  int getNumberOfItems() => _data.length;

  InputsRowData getRowData(int listIndex) {
    _Data x = _data[listIndex];
    final name = Strings.get(SDE.items[x.tid]!.nameLocalizations);
    final totalCost = currencyFormatNumber(x.totalCost);
    final costPerUnit = currencyFormatNumber(x.costPerUnit);
    return InputsRowData(name, totalCost, costPerUnit);
  }
}

class _Data {
  final int tid;
  final double totalCost;
  final double costPerUnit;

  const _Data(this.tid, this.totalCost, this.costPerUnit);
}

class InputsRowData {
  final String name;
  final String totalCost;
  final String costPerUnit;

  const InputsRowData(this.name, this.totalCost, this.costPerUnit);
}
