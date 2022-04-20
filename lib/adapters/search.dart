import 'package:flutter/material.dart';

import 'build.dart';

class SearchAdapter with ChangeNotifier {
  final Build buildAdapter;

  SearchAdapter(this.buildAdapter);

  void addToBuild(int tid) {
    buildAdapter.add(tid, 1);
  }
}

// needs access to very basic profit calculation
//  getProfit(tid)
//    SimpleBuild
//       BuildOptions
//         maybe uses this
//       BuildItemOptions
//         maybe uses this
//       build env
//         everything on one line
//         try to use current build options?
//         super basic dependency calculations
//    Market
