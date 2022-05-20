import 'package:flutter/material.dart';

import '../math.dart';
import '../misc.dart';
import '../sde.dart';
import '../sde_extra.dart';
import '../strings.dart';
import 'build.dart';
import 'market.dart';

enum _SortColumn {
  DEFAULT,
  COSTPERUNIT,
  ISKPERM3,
  M3,
}

enum _SortDir {
  ASC,
  DESC,
}

class InputsTableController with ChangeNotifier {
  final MarketController _market;
  final Build _build;

  final _data = <_Data>[];

  var _sortColumn = _SortColumn.DEFAULT;
  var _sortDir = _SortDir.DESC;

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
      final m3 = SD.m3(tid, bom[tid] ?? 0);
      final double iskPerM3 = m3 > 0 ? bomCosts[tid]! / m3 : 0.0;
      _data.add(_Data(tid, bomCosts[tid]!, bomCostsPerUnit[tid]!, m3, iskPerM3));
    }

    _resort();

    if (notify) {
      notifyListeners();
    }
  }

  void _resort() {
    switch (_sortColumn) {
      case _SortColumn.DEFAULT:
        _data.sort((a, b) => _sortFunc(a.totalCost, b.totalCost));
        break;
      case _SortColumn.COSTPERUNIT:
        _data.sort((a, b) => _sortFunc(a.costPerUnit, b.costPerUnit));
        break;
      case _SortColumn.M3:
        _data.sort((a, b) => _sortFunc(a.m3, b.m3));
        break;
      case _SortColumn.ISKPERM3:
        _data.sort((a, b) => _sortFunc(a.iskPerM3, b.iskPerM3));
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

  void sortTotalCost() => _advanceSortState(_SortColumn.DEFAULT);

  void sortCostPerUnit() => _advanceSortState(_SortColumn.COSTPERUNIT);

  void sortIskPerM3() => _advanceSortState(_SortColumn.ISKPERM3);

  void sortM3() => _advanceSortState(_SortColumn.M3);

  int getNumberOfItems() => _data.length;

  InputsRowData getRowData(int listIndex) {
    _Data x = _data[listIndex];
    final name = Strings.get(SDE.items[x.tid]!.nameLocalizations);
    final totalCost = currencyFormatNumber(x.totalCost);
    final costPerUnit = currencyFormatNumber(x.costPerUnit);
    final iskPerM3 = currencyFormatNumber(x.iskPerM3);
    final m3 = volumeNumberFormat(x.m3);
    return InputsRowData(name, totalCost, costPerUnit, m3, iskPerM3);
  }

  String exportCSV() {
    List<String> result = ['Name,Total Cost,Cost/Unit,M3,Isk/M3'];
    for (var data in _data) {
      result.add(data.toCSVString());
    }
    return result.join('\n');
  }
}

class _Data {
  final int tid;
  final double totalCost;
  final double costPerUnit;
  final double m3;
  final double iskPerM3;

  const _Data(this.tid, this.totalCost, this.costPerUnit, this.m3, this.iskPerM3);

  String toCSVString() {
    final name = Strings.get(SDE.items[tid]!.nameLocalizations);
    return name + ',' + totalCost.toString() + ',' + costPerUnit.toString() + ',' + m3.toString() + ',' + iskPerM3.toString();
  }
}

class InputsRowData {
  final String name;
  final String totalCost;
  final String costPerUnit;
  final String m3;
  final String iskPerM3;

  const InputsRowData(this.name, this.totalCost, this.costPerUnit, this.m3, this.iskPerM3);
}
