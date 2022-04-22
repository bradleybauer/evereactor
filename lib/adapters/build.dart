import 'package:EveIndy/models/industry_type.dart';
import 'package:EveIndy/solver/solver.dart';
import 'package:flutter/material.dart';

import '../sde_extra.dart';
import '../solver/problem.dart';
import '../solver/schedule.dart';
import 'build_items.dart';
import 'build_options.dart';
import 'inventory.dart';

class Build with ChangeNotifier {
  final InventoryAdapter _inventory;
  final BuildOptionsAdapter _buildOptions;
  final BuildItemsAdapter _buildItems;

  Schedule? _schedule;

  Build(this._inventory, this._buildOptions, this._buildItems) {
    _buildItems.addListener(_handleBuildChanged);
    _buildOptions.addListener(_handleBuildChanged);
    _inventory.addListener(_handleBuildChanged);

    _schedule = Approximator.get(_getOptimizationProblem());
  }

  void _handleBuildChanged() {
    _schedule = Approximator.get(_getOptimizationProblem());
    print(_schedule.toString());
    notifyListeners();
  }

  Problem _getOptimizationProblem() {
    final runsExcess = _buildItems.getTarget2Runs();
    final tids = _getAllTypeIds(runsExcess.keys);
    final dependencies = _getBuildDependencies(tids);
    final maxNumSlotsOfMachine = {IndustryType.MANUFACTURING: 100, IndustryType.REACTION: 150};
    final maxNumSlotsOfJob = tids.map((tid) => MapEntry(tid, 25));
    final maxNumRunsPerSlotOfJob = tids.map((tid) => MapEntry(tid, 100000));
    final jobMaterialBonus = tids.map((tid) => MapEntry(tid, 1.0 - 0.0));
    final jobTimeBonus = tids.map((tid) => MapEntry(tid, 1.0 - 0.0));
    return Problem(
      runsExcess: runsExcess,
      tids: tids,
      dependencies: dependencies,
      inventory: _inventory.getInventoryCopy(),
      maxNumSlotsOfMachine: maxNumSlotsOfMachine,
      maxNumSlotsOfJob: Map.fromEntries(maxNumSlotsOfJob),
      maxNumRunsPerSlotOfJob: Map.fromEntries(maxNumRunsPerSlotOfJob),
      jobMaterialBonus: Map.fromEntries(jobMaterialBonus),
      jobTimeBonus: Map.fromEntries(jobTimeBonus),
    );
  }

  // Get all the unique item ids that will be built by the scheduler.
  Set<int> _getAllTypeIds(Iterable<int> targets) {
    final res = <int>{};
    for (int tid in targets) {
      res.addAll(__getAllTypeIds(tid));
    }
    return res;
  }

  Set<int> __getAllTypeIds(int pid) {
    final res = <int>{pid};
    for (int cid in SD.materials(pid).keys) {
      if (_shouldBuild(pid, cid)) {
        res.addAll(__getAllTypeIds(cid));
      }
    }
    return res;
  }

  // Given the parent and child, returns whether child should be built.
  bool _shouldBuild(int pid, int cid) {
    final wrongIndyType = SD.isBuildable(pid) &&
        SD.isBuildable(cid) &&
        SD.industryType(pid) == IndustryType.REACTION &&
        SD.industryType(cid) == IndustryType.MANUFACTURING; // if pid is a reaction and cid is a fuel block
    return SD.isBuildable(cid) && _buildItems.shouldBuild(cid) && !wrongIndyType;
  }

  Map<int, Map<int, int>> _getBuildDependencies(Iterable<int> tids) {
    final deps = <int, Map<int, int>>{};
    for (int tid in tids) {
      deps[tid] = _getBuildDependenciesForItem(tid);
    }
    return deps;
  }

  Map<int, int> _getBuildDependenciesForItem(int pid) {
    return Map.fromEntries(SD.materials(pid).entries.where((e) => _shouldBuild(pid, e.key)));
  }
}

// build
//   get multi-buy
//   get total build time
//   get total output volume
//   get output volume (tid)
//   get bom
//   "get product info"
//   "get build string"
//   set/clear inv
//
// targets table adapter
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
