import 'dart:math';

import 'package:flutter/material.dart';

import '../models/build_items.dart';

class BuildItemsController extends BuildItems with ChangeNotifier {
  @override
  void addTarget(int tid, int runs) {
    super.addTarget(tid, runs);
    notifyListeners();
  }

  @override
  void removeTarget(int tid) {
    super.removeTarget(tid);
    notifyListeners();
  }

  @override
  void setRuns(int tid, int runs) {
    runs = max(1, runs);
    super.setRuns(tid, runs);
    notifyListeners();
  }

  @override
  void setME(int tid, int? ME) {
    super.setME(tid, ME);
    notifyListeners();
  }

  @override
  void setTE(int tid, int? TE) {
    super.setTE(tid, TE);
    notifyListeners();
  }

  @override
  void setMaxRuns(int tid, int? maxRuns) {
    super.setMaxRuns(tid, maxRuns);
    notifyListeners();
  }

  @override
  void setMaxBPs(int tid, int? maxBPs) {
    super.setMaxBPs(tid, maxBPs);
    notifyListeners();
  }

  @override
  void setShouldBuild(int tid, bool build) {
    super.setShouldBuild(tid, build);
    notifyListeners();
  }
}
