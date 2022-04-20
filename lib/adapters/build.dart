import 'package:flutter/material.dart';

import '../adapters/market.dart';
import '../models/build_item_options.dart';

class BuildAdapter with ChangeNotifier{
  BuildItemOptions buildItemOptions;
  MarketAdapter marketAdapter;

  BuildAdapter(this.buildItemOptions, this.marketAdapter) {
    marketAdapter.addListener(_handleMarketChanged);
  }

  void _handleMarketChanged() {}

  void add(int tid, int runs) {
    buildItemOptions.add(tid, runs);
    notifyListeners();
  }
  void remove(int tid) {
    buildItemOptions.remove(tid);
    notifyListeners();
  }
}


// build integrator
//   -inventoryAdapter
//   -buildEnvAdapter
//   -buildItemsAdapter - runs/buildOrBuy/BpOps
//   -marketAdapter
//   get multi-buy
//   get total cost
//   get total profit
//   get cost (tid)
//   get profit (tid)
//   get total build time
//    ...
//   "get schedule"
//   "get output info"
//   "get build string" // pass thru
//   set/clear inv // pass thru
//   add/remove items // pass thru
//
// build
//   get total output volume
//   get output volume (tid)
//
// targets table
//  get rows
