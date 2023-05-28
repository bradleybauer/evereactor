import 'package:flutter/material.dart';

import '../industry.dart';
import '../models/industry_type.dart';
import '../models/inventory.dart';
import '../sde_extra.dart';
import '../solver/basic_solver.dart';
import '../solver/problem.dart';
import '../solver/schedule.dart';
import 'build_items.dart';
import 'inventory.dart';
import 'options.dart';
import 'schedule_provider.dart';

class ScheduleProviderWeb extends ChangeNotifier implements ScheduleProvider {
  final InventoryController inventory;
  final OptionsController options;
  final BuildItemsController buildItems;

  ScheduleProviderWeb({required this.inventory, required this.buildItems, required this.options}) {
    buildItems.addListener(handleBuildChanged);
    options.addListener(handleBuildChanged);
    inventory.addListener(handleBuildChanged);
  }

  Problem? _problem;
  Schedule? _basicSchedule;

  @override
  Problem? getProblem() => _problem;

  @override
  Schedule? getSchedule() => _basicSchedule;

  @override
  Map<int, int> getTid2Runs() => buildItems.getTarget2RunsCopy();

  @override
  Inventory getInventoryCopy() => inventory.getInventoryCopy();

  @override
  Set<int> getTargetsIDs() => buildItems.getTargetsIDs();

  void handleBuildChanged() {
    computeNewBasicSchedule();
    notifyListeners();
  }

  @override
  void computeNewBasicSchedule() {
    final tid2runs = buildItems.getTarget2RunsCopy();
    final allBuiltItems = buildItems.getItemsInBuild();
    _problem = _getOptimizationProblem(tid2runs, allBuiltItems);
    _basicSchedule = BasicSolver.getSchedule(_problem!);
  }

  Problem _getOptimizationProblem(Map<int, int> tid2runs, Set<int> allBuiltItems) {
    final maxNumSlotsOfMachine = {
      IndustryType.MANUFACTURING: options.getManufacturingSlots(),
      IndustryType.REACTION: options.getReactionSlots()
    };
    final maxNumSlotsOfJob = allBuiltItems.map((tid) => MapEntry(tid, buildItems.getMaxBPs(tid) ?? options.getMaxNumBlueprints()));
    final maxNumRunsPerSlotOfJob = allBuiltItems.map((tid) => MapEntry(tid, buildItems.getMaxRuns(tid) ?? 10000000));
    final jobMaterialBonus = allBuiltItems.map((tid) => MapEntry(tid, getMaterialBonus(tid, options, buildItems)));
    final jobTimeBonus = allBuiltItems.map((tid) => MapEntry(tid, getTimeBonus(tid, options, buildItems)));
    return Problem(
      runsExcess: tid2runs,
      tids: allBuiltItems,
      dependencies: _getBuildDependencies(allBuiltItems),
      inventory: inventory.getInventoryCopy(),
      maxNumSlotsOfMachine: maxNumSlotsOfMachine,
      maxNumSlotsOfJob: Map.fromEntries(maxNumSlotsOfJob),
      maxNumRunsPerSlotOfJob: Map.fromEntries(maxNumRunsPerSlotOfJob),
      jobMaterialBonus: Map.fromEntries(jobMaterialBonus),
      jobTimeBonus: Map.fromEntries(jobTimeBonus),
    );
  }

  Map<int, Map<int, int>> _getBuildDependencies(Iterable<int> tids) {
    final deps = <int, Map<int, int>>{};
    for (int tid in tids) {
      final temp = _getBuildDependenciesForItem(tid);
      if (temp.isNotEmpty) {
        deps[tid] = temp;
      }
    }
    return deps;
  }

  Map<int, int> _getBuildDependenciesForItem(int pid) =>
      Map.fromEntries(SD.materials(pid).entries.where((e) => buildItems.getShouldBuildChildOfParent(pid, e.key, excludeItemsSetToBuy: true)));

  @override
  String toCSV() {
    return "";
  }
}
