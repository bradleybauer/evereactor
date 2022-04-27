import 'dart:math';

import 'package:flutter/material.dart';

import '../models/build_items.dart';

class BuildItemsController with ChangeNotifier {
  final BuildItems _buildItems = BuildItems();

  void addTarget(int tid, int runs) {
    _buildItems.addTarget(tid, runs);
    notifyListeners();
  }

  void removeTarget(int tid) {
    _buildItems.removeTarget(tid);
    notifyListeners();
  }

  void restrict(Set<int> targets, Set<int> intermediates) => _buildItems.restrict(targets, intermediates);

  int getNumberOfTargets() => _buildItems.getNumberOfTargets();

  List<int> getTargetsIds() => _buildItems.getTargetsIds();

  int getTargetRuns(int id) => _buildItems.getTargetRuns(id);

  Map<int, int> getTarget2Runs() => _buildItems.getTarget2Runs();

  bool shouldBuild(int tid) => _buildItems.shouldBuild(tid);

  void setRuns(int tid, int runs) {
    runs = max(1, runs);
    _buildItems.setRuns(tid, runs);
    notifyListeners();
  }

  void setME(int tid, int? ME) {
    _buildItems.setME(tid, ME);
    notifyListeners();
  }

  void setTE(int tid, int? TE) {
    _buildItems.setTE(tid, TE);
    notifyListeners();
  }

  void setMaxRuns(int tid, int? maxRuns) {
    _buildItems.setMaxRuns(tid, maxRuns);
    notifyListeners();
  }

  void setMaxBPs(int tid, int? maxBPs) {
    _buildItems.setMaxBPs(tid, maxBPs);
    notifyListeners();
  }

  int? getME(int tid) => _buildItems.getME(tid);

  int? getTE(int tid) => _buildItems.getTE(tid);

  int? getMaxRuns(int tid) => _buildItems.getMaxRuns(tid);

  int? getMaxBPs(int tid) => _buildItems.getMaxBPs(tid);

  void setShouldBuild(int tid, bool build) {
    _buildItems.setShouldBuild(tid, build);
    notifyListeners();
  }

  bool getShouldBuild(int tid) => _buildItems.getShouldBuild(tid);
}
