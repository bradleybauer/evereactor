import 'package:flutter/material.dart';

import 'build_items.dart';
import 'build_options.dart';
import 'inventory.dart';

class Build with ChangeNotifier {
  InventoryAdapter inventory;
  BuildOptionsAdapter buildOptions;
  BuildItemsAdapter buildItems;

  Build(this.inventory, this.buildOptions, this.buildItems) {
    buildItems.addListener(_handleBuildChanged);
    buildOptions.addListener(_handleBuildChanged);
    inventory.addListener(_handleBuildChanged);
  }

  void _handleBuildChanged() {
    // update schedule
    notifyListeners();
  }

  void add(int tid, int runs) => buildItems.add(tid, runs);

  void remove(int tid) => buildItems.remove(tid);
}

// buildAdapter
//   get multi-buy
//   get total build time
//   get total output volume
//   get output volume (tid)
//   get bom
//   "get product info"
//   "get build string"
//   set/clear inv
//
// targets table
//  get rows

/*
class ChainProcessor {
  var _arg = '';
  var didUpdateArg = false;
  bool isComputing = false;

  Future<void> _computation(arg) async {
    print('Computation('+arg+') start');
    await Future.delayed(const Duration(seconds: 3));
    print('Computation('+arg+') done');
  }

  void chain() async {
    do {
      didUpdateArg = false;
      await _computation(_arg);
    } while (didUpdateArg);
    isComputing = false;
  }

  void compute(nextarg) {
    _arg = nextarg;
    if (!isComputing) {
      isComputing = true;
      chain();
    } else {
      didUpdateArg = true;
    }
  }
}

Future<void> main() async {
  final processor = ChainProcessor();

  // initial computation request
  processor.compute('1');

  // new computation requests with different arguments
  Future.delayed(const Duration(seconds: 1), () => processor.compute('2'));
  Future.delayed(const Duration(milliseconds: 1500), () => processor.compute('3'));

  // but only the argument in the most recent request is computed
  Future.delayed(const Duration(milliseconds: 1600), () => processor.compute('4'));

  // when no computation is being done, more chains can be started
  Future.delayed(const Duration(seconds: 11), () => processor.compute('5'));
  Future.delayed(const Duration(seconds: 12), () => processor.compute('6'));
}
 */