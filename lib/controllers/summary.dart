import 'package:EveIndy/controllers/controllers.dart';
import 'package:flutter/material.dart';

import 'package:EveIndy/misc.dart';
import '../math.dart';
import '../sde_extra.dart';
import '../strings.dart';
import 'build.dart';
import 'market.dart';

class SummaryController with ChangeNotifier {
  final MarketController _market;
  final BuildItemsController _buildItems;
  final OptionsController _options;
  final Build _build;

  SummaryData data = const SummaryData('', '', '', '');

  SummaryController(this._market, this._buildItems, this._build, this._options, Strings strings) {
    _market.addListener(_handleModelChange);
    _build.addListener(_handleModelChange);
    strings.addListener(() {
      notifyListeners();
    });
  }

  void _handleModelChange({notify = true}) {
    final bom = _build.getBOM();
    final bomCostsPerUnit = _market.avgBuyFromSell(bom);
    final bomCosts = prod(bom, bomCostsPerUnit);
    final target2runs = _buildItems.getTarget2RunsCopy();
    final totalSellValue = target2runs.entries.fold(0.0, (double p, e) {
      final tid = e.key;
      final runs = e.value;
      final qty = SD.numProducedPerRun(tid) * runs;
      return p + _market.avgSellToBuyItem(tid, qty) * qty;
    });
    final cost = bomCosts.values.fold(0.0, (double p, e) => p + e);
    final profit  =(1 - _options.getSalesTaxPercent() / 100) * totalSellValue - cost;
    data = SummaryData(currencyFormatNumber(profit), currencyFormatNumber(cost), '0', '0');

    // TODO sort the data

    if (notify) {
      notifyListeners();
    }
  }

  SummaryData getData() => data;
}

class SummaryData {
  final String profit;
  final String cost;
  final String inm3;
  final String outm3;

  const SummaryData(this.profit, this.cost, this.inm3, this.outm3);
}
