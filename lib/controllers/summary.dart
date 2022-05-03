import 'package:flutter/material.dart';

import '../industry.dart';
import '../math.dart';
import '../misc.dart';
import '../sde_extra.dart';
import '../strings.dart';
import 'controllers.dart';

class SummaryController with ChangeNotifier {
  final MarketController _market;
  final BuildItemsController _buildItems;
  final OptionsController _options;
  final Build _build;

  SummaryData data = const SummaryData('', '', '', '', '', '');

  SummaryController(this._market, this._buildItems, this._build, this._options, Strings strings) {
    _market.addListener(_handleModelChange);
    _build.addListener(_handleModelChange);
    strings.addListener(() {
      notifyListeners();
    });
  }

  void _handleModelChange() {
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
    final jobCost = getCostOfJobs(_build.getSchedule(), _market.getAdustedPrices(), _options.getManufacturingSystemCostIndex(),
        _options.getReactionSystemCostIndex(), _options.getManufacturingCostBonus() ?? 0);
    final profit = (1 - _options.getSalesTaxPercent() / 100) * totalSellValue - cost - jobCost;
    final outm3 = target2runs.entries.fold(0.0, (double p, e) => p + SD.m3(e.key, e.value * SD.numProducedPerRun(e.key)));
    final inm3 = bom.entries.fold(0.0, (double p, e) => p + SD.m3(e.key, e.value));
    final time = prettyPrintSecondsToDH(_build.getTime());
    data = SummaryData(currencyFormatNumber(profit), currencyFormatNumber(cost), currencyFormatNumber(jobCost), volumeNumberFormat(inm3),
        volumeNumberFormat(outm3), time);

    notifyListeners();
  }

  SummaryData getData() => data;
}

class SummaryData {
  final String profit;
  final String cost;
  final String jobCost;
  final String inm3;
  final String outm3;
  final String time;

  const SummaryData(this.profit, this.cost, this.jobCost, this.inm3, this.outm3, this.time);
}
