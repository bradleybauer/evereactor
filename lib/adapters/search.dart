import 'package:flutter/material.dart';

import 'build.dart';

class SearchAdapter with ChangeNotifier {
  final BuildAdapter buildAdapter;

  SearchAdapter(this.buildAdapter);

  void addToBuild(int tid) {
    buildAdapter.add(tid, 1);
  }
}

// needs access to very basic profit calculation
//  getProfit(tid)
//    build env
//      everything on one line
//      try to use current build options?
//      super basic dependency calculations
//    accesses market
