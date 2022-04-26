import 'dart:math';

import 'package:EveIndy/models/blueprint.dart';
import 'package:EveIndy/models/bonus_type.dart';
import 'package:EveIndy/models/industry_type.dart';
import 'package:EveIndy/solver/solver.dart';
import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';

import '../math.dart';
import '../models/rig.dart';
import '../sde.dart';
import '../sde_extra.dart';
import '../solver/problem.dart';
import '../solver/schedule.dart';
import 'build_items.dart';
import 'inventory.dart';
import 'options.dart';

class Build with ChangeNotifier {
  final InventoryAdapter _inventory;
  final OptionsAdapter _options;
  final BuildItemsAdapter _buildItems;

  var _allBuiltItems = <int>{};
  var _intermediates = <int>{};

  var _totalBOM = <int, int>{};

  // var _targetBOM = <int,int>{};

  Schedule? _schedule;

  Build(this._inventory, this._options, this._buildItems) {
    _buildItems.addListener(_handleBuildChanged);
    _options.addListener(_handleBuildChanged);
    _inventory.addListener(_handleBuildChanged);

    // TODO is this needed here?
    _schedule = Approximator.get(_getOptimizationProblem(_buildItems.getTarget2Runs()));
  }

  void _handleBuildChanged() {
    final tid2runs = _buildItems.getTarget2Runs();
    _intermediates = _getIntermediatesIDs(tid2runs.keys);
    _allBuiltItems = _intermediates.where((e) => _buildItems.shouldBuild(e)).toSet().union(tid2runs.keys.toSet());
    _buildItems.restrict(tid2runs.keys.toSet(), _intermediates);

    final problem = _getOptimizationProblem(tid2runs);
    _schedule = Approximator.get(problem);
    print(_schedule.toString());
    print((_schedule!.time.toDouble() / (3600 * 24)));

    _totalBOM = _getTotalBOM(tid2runs, problem);
    _totalBOM.forEach((int tid, int needed) {
      print(SD.enName(tid) + ' : ' + needed.toString());
    });

    notifyListeners();
  }

  Map<int, int> _getTotalBOM(Map<int, int> targets, Problem problem) {
    final inventory = _inventory.getInventoryCopy();

    final produced = <int, int>{};

    /// if needed is not initialized like this, then the following can occur:
    ///   if sylFib is set to buy but is also a target then, consider where sylFib is produced in batch 0 and
    ///   a consumer of sylFib is produced in batch 0 (for simpl there is only 1 batch). Then targetNumRuns of sylFib is set in
    ///   produced and numAsDeps of sylFib is set in required. This causes targetNumRuns to cancel out some of numAsDeps
    ///   (in return statement) which is not supposed to happen.
    final needed = targets.map((target, runs) => MapEntry(target, runs * SD.numProducedPerRun(target)));
    for (List<Batch> batches in _schedule!.getBatches().values) {
      for (Batch batch in batches) {
        batch.getItems().forEach((tid, batchItem) {
          final runs = batchItem.runs;
          if (!produced.containsKey(tid)) produced[tid] = 0;
          produced[tid] = produced[tid]! + runs * SD.numProducedPerRun(tid);
          SD.materials(tid).forEach((mid, qtyPerRun) {
            final slots = batchItem.slots;
            if (!needed.containsKey(mid)) needed[mid] = 0;
            needed[mid] = needed[mid]! + getNumNeeded(runs, slots, qtyPerRun, problem.jobMaterialBonus[tid]!);
          });
        });
      }
    }
    final result = <int, int>{};
    needed.forEach((int mid, int numNeeded) {
      if (!produced.containsKey(mid)) produced[mid] = 0;
      int newNumNeeded = max(0, numNeeded - produced[mid]! - inventory.get(mid));
      if (newNumNeeded != 0) {
        result[mid] = newNumNeeded;
      }
    });

    return result;
  }

  // Get all the unique item ids that will be built by the scheduler.
  Set<int> _getIntermediatesIDs(Iterable<int> targets) {
    final res = <int>{};
    for (int tid in targets) {
      res.addAll(__getIntermediatesIDs(tid));
    }
    return res;
  }

  Set<int> __getIntermediatesIDs(int pid) {
    final res = <int>{};
    for (int cid in SD.materials(pid).keys) {
      if (_shouldBuild(pid, cid, useBuildItems: false)) {
        res.add(cid);
        res.addAll(__getIntermediatesIDs(cid));
      }
    }
    return res;
  }

  // Given the parent and child, returns whether child should be built.
  bool _shouldBuild(int pid, int cid, {required bool useBuildItems}) {
    final wrongIndyType = SD.isBuildable(pid) &&
        SD.isBuildable(cid) &&
        SD.industryType(pid) == IndustryType.REACTION &&
        SD.industryType(cid) == IndustryType.MANUFACTURING; // if pid is a reaction and cid is a fuel block
    if (useBuildItems) {
      return SD.isBuildable(cid) && _buildItems.shouldBuild(pid) && _buildItems.shouldBuild(cid) && !wrongIndyType;
    } else {
      return SD.isBuildable(cid) && !wrongIndyType;
    }
  }

  Problem _getOptimizationProblem(Map<int, int> tid2runs) {
    final maxNumSlotsOfMachine = {
      IndustryType.MANUFACTURING: _options.getManufacturingSlots(),
      IndustryType.REACTION: _options.getReactionSlots()
    };
    final maxNumSlotsOfJob =
        _allBuiltItems.map((tid) => MapEntry(tid, _buildItems.getMaxBPs(tid) ?? _options.getMaxNumBlueprints()));
    final maxNumRunsPerSlotOfJob = _allBuiltItems.map((tid) => MapEntry(tid, _buildItems.getMaxRuns(tid) ?? 1000000000));
    final jobMaterialBonus = _allBuiltItems.map((tid) => MapEntry(tid, _getMaterialBonus(tid)));
    final jobTimeBonus = _allBuiltItems.map((tid) => MapEntry(tid, _getTimeBonus(tid, _options.getSkills())));
    return Problem(
      runsExcess: tid2runs,
      tids: _allBuiltItems,
      dependencies: _getBuildDependencies(_allBuiltItems),
      inventory: _inventory.getInventoryCopy(),
      maxNumSlotsOfMachine: maxNumSlotsOfMachine,
      maxNumSlotsOfJob: Map.fromEntries(maxNumSlotsOfJob),
      maxNumRunsPerSlotOfJob: Map.fromEntries(maxNumRunsPerSlotOfJob),
      jobMaterialBonus: Map.fromEntries(jobMaterialBonus),
      jobTimeBonus: Map.fromEntries(jobTimeBonus),
    );
  }

  Fraction _getMaterialBonus(int tid) {
    final bp = SDE.blueprints[tid]!;
    switch (bp.industryType) {
      case IndustryType.REACTION:
        return _getReactionMaterialBonus(tid, bp);
      case IndustryType.MANUFACTURING:
        return _getManufacturingMaterialBonus(tid, bp);
    }
  }

  Fraction _getManufacturingMaterialBonus(int tid, Blueprint bp) {
    var ret = 1.toFraction();

    // structures
    final structure = SDE.structures[_options.getManufacturingStructure().tid]!;
    if (structure.bonuses.containsKey(BonusType.MATERIAL)) {
      ret *= structure.bonuses[BonusType.MATERIAL]!.toFraction();
    }

    // rigs
    ret *= getRigBonus(tid, _options.getSelectedManufacturingRigs().map((e) => e.tid), BonusType.MATERIAL);

    // blueprint me settings
    ret *= 1.toFraction() - Fraction(_buildItems.getME(tid) ?? _options.getME(), 100);

    return ret.reduce();
  }

  // only rigs affect reaction ME
  Fraction _getReactionMaterialBonus(int tid, Blueprint bp) =>
      getRigBonus(tid, _options.getSelectedReactionRigs().map((e) => e.tid), BonusType.MATERIAL).reduce();

  Fraction _getTimeBonus(int tid, List<SkillsData> skills) {
    final bp = SDE.blueprints[tid]!;
    switch (bp.industryType) {
      case IndustryType.REACTION:
        return _getReactionTimeBonus(tid, bp, skills);
      case IndustryType.MANUFACTURING:
        return _getManufacturingTimeBonus(tid, bp, skills);
    }
  }

  // def s2l(s):
  //     d = floor(s / (3600 * 24))
  //     s -= d * 3600 * 24
  //     h = floor(s / 3600)
  //     s -= h * 3600
  //     m = floor(s / 60)
  //     s -= m * 60
  //     return [d,h,m, round(s)]
  Fraction _getManufacturingTimeBonus(int tid, Blueprint bp, List<SkillsData> skills) {
    var ret = 1.toFraction();

    // structure
    final structure = SDE.structures[_options.getManufacturingStructure().tid]!;
    if (structure.bonuses.containsKey(BonusType.TIME)) {
      ret *= structure.bonuses[BonusType.TIME]!.toFraction();
    }

    // rigs
    ret *= getRigBonus(tid, _options.getSelectedManufacturingRigs().map((e) => e.tid), BonusType.TIME);

    // skill
    ret *= getSkillBonus(tid, bp, skills);

    // bp
    ret *= 1.toFraction() - Fraction(_buildItems.getTE(tid) ?? _options.getTE(), 100);

    return ret.reduce();
  }

  Fraction _getReactionTimeBonus(int tid, Blueprint bp, List<SkillsData> skills) {
    var ret = 1.toFraction();

    // structure
    final structure = SDE.structures[_options.getReactionStructure().tid]!;
    if (structure.bonuses.containsKey(BonusType.TIME)) {
      ret *= structure.bonuses[BonusType.TIME]!.toFraction();
    }

    // rigs
    ret *= getRigBonus(tid, _options.getSelectedReactionRigs().map((e) => e.tid), BonusType.TIME);

    // skill
    ret *= getSkillBonus(tid, bp, skills);

    return ret.reduce();
  }

  bool shouldApplyRig(int tid, Rig rig) {
    int groupID = SDE.items[tid]!.groupID;
    int categoryID = SDE.group2category[groupID]!; // groupID parent
    return rig.domainGroupIDs.contains(groupID) || rig.domainCategoryIDs.contains(categoryID);
  }

  Fraction getRigBonus(int tid, Iterable<int> rigs, BonusType bonusType) {
    Fraction bestRigBonus = 1.toFraction();
    for (int rigID in rigs) {
      final rig = SDE.rigs[rigID]!;
      if (rig.bonuses.containsKey(bonusType)) {
        if (shouldApplyRig(tid, rig)) {
          // Only apply the best material bonus, in the case that multiple rigs give a bonus to the same item.
          // If I supported multiple structures (each with only 3 rigs at most) then, for each item i would have to
          // choose a structure. I would choose the best structure... like how do i define that? what if one structure
          // is rigged for ME and another for TE, then what is more important ME or TE?
          // well let the user decide... now u have to design the ui to let the user decide, and also have to explain
          // it to the user so it makes sense. 'prefer to build item in structure with best [ME / TE button]'.
          // Now you have to tell the user how much of what materials go where...
          // can be done.. but damn.
          // that's a project for another month.
          // One use case would be where an alliance has two Mfg structures:
          //    one rigged for components and another rigged for ship mfg..
          // meh..
          final rigBonus = 1.toFraction() + rig.bonuses[bonusType]!.toFraction() / 100.toFraction();
          if (rigBonus < bestRigBonus) {
            bestRigBonus = rigBonus;
          }
        }
      }
    }
    return bestRigBonus.reduce();
  }

  Fraction getSkillBonus(int tid, Blueprint bp, List<SkillsData> skills) {
    var ret = 1.toFraction();
    for (var skillData in skills) {
      if (bp.skills.contains(skillData.tid)) {
        ret *= 1.toFraction() +
            skillData.level.toFraction() * SDE.skills[skillData.tid]!.bonus.toFraction() / 100.toFraction();
      }
    }
    return ret.reduce();
  }

  Map<int, Map<int, int>> _getBuildDependencies(Iterable<int> tids) {
    final deps = <int, Map<int, int>>{};
    for (int tid in tids) {
      deps[tid] = _getBuildDependenciesForItem(tid);
    }
    return deps;
  }

  Map<int, int> _getBuildDependenciesForItem(int pid) =>
      Map.fromEntries(SD.materials(pid).entries.where((e) => _shouldBuild(pid, e.key, useBuildItems: true)));

  List<int> getIntermediatesIds() => _intermediates.toList(growable: false);

  List<int> getInputIds() => _totalBOM.keys.toList();
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
