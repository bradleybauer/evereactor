import 'package:flutter/material.dart';

import '../models/build_items.dart';
import '../sde_extra.dart';

class BuildItemsAdapter with ChangeNotifier {
  final BuildItems _buildItems = BuildItems();

  void add(int tid, int runs) {
    _buildItems.add(tid, runs);
    notifyListeners();
  }

  void remove(int tid) {
    _buildItems.remove(tid);
    notifyListeners();
  }

  int getNumberOfTargets() => _buildItems.getNumberOfTargets();

  List<int> getTargetsIds() => _buildItems.getTargetsIds();

  int? getTargetRuns(int id) => _buildItems.getTargetRuns(id);

  Map<int,int> getTarget2Runs() => _buildItems.getTarget2Runs();

  bool shouldBuild(int tid) => _buildItems.shouldBuild(tid);
}
