import 'package:EveIndy/models/build_options.dart';
import 'package:flutter/material.dart';

import '../models/build_items.dart';
import '../models/inventory.dart';

class Build with ChangeNotifier{
  Inventory inventory;
  BuildOptions buildOptions;
  BuildItems buildItems;

  Build(this.inventory, this.buildOptions, this.buildItems);

  void add(int tid, int runs) {
    buildItems.add(tid, runs);
    notifyListeners();
  }

  void remove(int tid) {
    buildItems.remove(tid);
    notifyListeners();
  }
}


// buildAdapter
//   -inventoryAdapter
//   -buildOptionsAdapter
//   -buildItemsAdapter - runs/buildOrBuy/BpOps
//   get multi-buy
//   get total build time
//   get total output volume
//   get output volume (tid)
//   get bom
//   "get schedule"
//   "get output info"
//   "get build string"
//   set/clear inv
//   add/remove items (mutates builditems)
//
// targets table
//  get rows
