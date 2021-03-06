import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';

import '../industry.dart';
import '../sde_extra.dart';
import '../solver/problem.dart';
import '../solver/schedule.dart';
import 'schedule_provider.dart';

class Build with ChangeNotifier {
  final ScheduleProvider _scheduleProvider;

  var _totalBOM = <int, int>{};
  var _target2costShare = <int, Map<int, double>>{};

  Schedule _schedule = Schedule.empty();

  Build(this._scheduleProvider) {
    _scheduleProvider.addListener(_onNewSchedule);
  }

  void _onNewSchedule() {
    final tid2runs = _scheduleProvider.getTid2Runs();
    final schedule = _scheduleProvider.getSchedule();
    final problem = _scheduleProvider.getProblem();
    // TODO handle errors!
    if (schedule != null) {
      _schedule = schedule;
      _totalBOM = _getTotalBOM(tid2runs, problem!);
      _target2costShare = _getShares(tid2runs, problem);
    } else {
      // TODO null represents a scheduling error. nothing shown on the screen should be changed in such an error.
      //_schedule = Schedule.empty();
      //_totalBOM.clear();
      //_target2costShare.clear();
    }
    notifyListeners();
  }

  // get map tid -> quantity where quantity is the amount of tid that needs to be purchased in order to do the build.
  // [schedule] is a list of batches
  // batch is a map tid->(runs,lines)
  // [buildItems] is the item level build information
  // The BOM (Bill Of Materials) is whatever is required by produced that is not supplied by inventory
  Map<int, int> _getTotalBOM(Map<int, int> targets, Problem problem) {
    final inventory = _scheduleProvider.getInventoryCopy();

    final produced = <int, int>{};

    /// if needed is not initialized like this, then the following can occur:
    ///   if sylFib is set to buy but is also a target then, consider where sylFib is produced in batch 0 and
    ///   a consumer of sylFib is produced in batch 0 (for simpl there is only 1 batch). Then targetNumRuns of sylFib is set in
    ///   produced and numAsDeps of sylFib is set in required. This causes targetNumRuns to cancel out some of numAsDeps
    ///   (in return statement) which is not supposed to happen.
    final needed = targets.map((target, runs) => MapEntry(target, runs * SD.numProducedPerRun(target)));
    for (List<Batch> batches in _schedule.getBatches().values) {
      for (Batch batch in batches) {
        batch.getItems().forEach((tid, batchItem) {
          final runs = batchItem.runs;
          if (!produced.containsKey(tid)) produced[tid] = 0;
          produced[tid] = produced[tid]! + runs * SD.numProducedPerRun(tid);
          SD.materials(tid).forEach((mid, qtyPerRun) {
            final slots = batchItem.slots;
            if (!needed.containsKey(mid)) needed[mid] = 0;
            needed[mid] = needed[mid]! + getNumNeeded(runs, slots, qtyPerRun, problem.jobMaterialBonus[tid] ?? 1.toFraction());
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

  Map<int, Map<int, double>> _getShares(Map<int, int> targets, Problem problem) {
    // the first part of this algorithm calculates a table of doubles with size (num materials, num targets)

    // how much mid is needed by each parent of mid
    // mid -> (pid -> number mid needed by pid)
    // for any given mid, this can be seen as a tree where mid is the root.
    Map<int, Map<int, double>> mid2numNeeded = {};
    // the total number of runs of tid scheduled
    // tid -> totalNumRuns
    Map<int, int> totalRuns = {};
    // calculate mid2numNeeded and totalRuns
    _schedule.getBatches().forEach((_, batches) {
      for (var batch in batches) {
        batch.items.forEach((tid, batchItem) {
          if (!totalRuns.containsKey(tid)) totalRuns[tid] = 0;
          totalRuns[tid] = totalRuns[tid]! + batchItem.runs;
          SD.materials(tid).forEach((mid, qtyPerRun) {
            if (!mid2numNeeded.containsKey(mid)) mid2numNeeded[mid] = {};
            if (!mid2numNeeded[mid]!.containsKey(tid)) mid2numNeeded[mid]![tid] = 0;
            // parent wants numNeeded more of child
            mid2numNeeded[mid]![tid] =
                mid2numNeeded[mid]![tid]! + getNumNeeded(batchItem.runs, batchItem.slots, qtyPerRun, problem.jobMaterialBonus[tid]!);
          });
        });
      }
    });
    // for items that are both dependents and targets we need to treat them differently
    for (var mid in mid2numNeeded.keys.toList()) {
      final pid2qty = mid2numNeeded[mid]!;
      for (var pid in pid2qty.keys.toList()) {
        if (_scheduleProvider.getTargetsIDs().contains(pid) && mid2numNeeded.containsKey(pid)) {
          final fractionAsTarget = targets[pid]! / totalRuns[pid]!;
          // Creates a leaf in the tree since -pid is NOT in mid2numNeeded since it is not a mid (no material has negative id)
          mid2numNeeded[mid]![-pid] = mid2numNeeded[mid]![pid]! * fractionAsTarget;
          mid2numNeeded[mid]![pid] = mid2numNeeded[mid]![pid]! * (1 - fractionAsTarget);
        }
      }
    }
    mid2numNeeded.keys.toList().forEach((mid) {
      // normalize the quantities
      final pid2qty = mid2numNeeded[mid]!;
      double sum = pid2qty.values.fold(0.0, (v, qty) => v + qty);
      pid2qty.keys.toList().forEach((pid) {
        pid2qty[pid] = pid2qty[pid]! / sum;
      });
    });
    final Map<int, Map<int, double>> tid2costShare = {};
    for (var mid in _totalBOM.keys) {
      _getShare(mid, mid2numNeeded).forEach((tid, share) {
        tid = tid.abs(); // in case tid is both target and dependency then tid is negative for target branch
        if (!tid2costShare.containsKey(tid)) {
          tid2costShare[tid] = {};
        }
        tid2costShare[tid]![mid] = share;
      });
    }
    return tid2costShare;
  }

  Map<int, double> _getShare(int mid, Map<int, Map<int, double>> mid2fractions) {
    final share = <int, double>{};
    // if this item is a target
    if (!mid2fractions.containsKey(mid)) {
      return {mid: 1.0};
    }

    // share is a weighted combination of parent shares
    mid2fractions[mid]!.forEach((pid, frac) {
      _getShare(pid, mid2fractions).forEach((tid, subshare) {
        if (!share.containsKey(tid)) share[tid] = 0;
        share[tid] = share[tid]! + frac * subshare;
      });
    });
    return share;
  }

  List<int> getInputIds() => _totalBOM.keys.toList();

  Map<int, double> getCostShare(int tid) => _target2costShare[tid]!;

  Map<int, int> getBOM() => _totalBOM;

  Schedule getSchedule() => _schedule;

  double getTime() => _schedule.time;
}
