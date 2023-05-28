import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:fraction/fraction.dart';

import '../industry.dart';
import '../math.dart';
import '../models/industry_type.dart';
import '../sde_extra.dart';
import 'problem.dart';
import 'schedule.dart';
import 'worker.dart';

class AdvancedSolver extends ChangeNotifier {
  Isolate? _currentWorker;

  // A port for listening for messages from the worker isolate
  final ReceivePort rp = ReceivePort();

  AdvancedSolver() {
    rp.listen(_handleReceiveMessage);
  }

  void _handleReceiveMessage(msg) {
    if (msg != null) {
      postProcessSchedule(msg!);
    }

    // else this is a stop message notify ui
    notifyListeners();
  }

  void solve(Problem prob) async {
    stop();
    _problem = prob;
    _currentWorker = await Isolate.spawn(startWorker, WorkerArg(prob, rp.sendPort));
  }

  void stop() async {
    if (_currentWorker != null) {
      stopWorker();
    }
    _currentWorker = null;
  }

  void postProcessSchedule(Schedule schedule) {
    if (schedule.isInfeasible || schedule.machine2batches.isEmpty) {
      _schedule = schedule;
      return;
    }
    final batchesByTime = _getBatchesByTime(schedule);
    // We never have a deficit of runs of anything. This is also asserted _assertValid.
    assert(_getExcess(batchesByTime).values.every((element) => element >= 0));

    // the given schedule is valid
    if (kDebugMode) {
      _assertValid(batchesByTime, noExcess: false);
    }

    // iterate backward to remove runs
    // TODO BB explain this better
    // Reducing the excess of item A can possibly increase the excess of it's children.
    // So after removing runs of any item we restart the below loop....
    // There are no cycles in dependencies so this should not be an infinite loop.
    for (int i = batchesByTime.length - 1; i >= 0; --i) {
      Map<int, int> excess = _getExcess(batchesByTime);
      if (updateExcess(batchesByTime[i], excess)) {
        i = batchesByTime.length - 1;
      }
    }

    // Remove any empty batches
    for (var machine in schedule.machine2batches.keys) {
      final batches = schedule.machine2batches[machine]!;
      for (int i = batches.length - 1; i >= 0; --i) {
        if (batches[i].items.isEmpty) {
          //print("removing batch!!!!!!!!!!!!!!!!!!!");
          batches.removeAt(i);
        }
      }
    }

    if (kDebugMode) {
      _assertValid(batchesByTime, noExcess: true, schedule: schedule);
    }

    // Removing excess potentially changes schedule time so compute new schedule time.
    var maxEndingTime = 0.toFraction();
    for (var batch in batchesByTime) {
      final endTime = batch.getEndTime();
      maxEndingTime = endTime > maxEndingTime ? endTime : maxEndingTime;
    }

    _schedule = schedule;
  }

  bool updateExcess(final Batch batch, final Map<int, int> excess) {
    bool itemChanged = false;
    for (final entry in batch.items.entries) {
      final tid = entry.key;
      final item = entry.value;
      if (excess.containsKey(tid)) {
        final excessRuns = (excess[tid]! / SD.numProducedPerRun(tid).toDouble()).floor();
        assert(excess[tid]! >= 0);
        if (excessRuns > 0) {
          itemChanged = true;

          final newRuns = item.runs - excessRuns;
          if (newRuns > 0) {
            assert(item.slots >= 1);
            final newSlots = min(newRuns, item.slots);
            Fraction newTime = ((ceilDiv(newRuns, newSlots) * SD.timePerRun(tid)).toFraction() * _problem!.jobTimeBonus[tid]!).reduce();
            batch[tid] = BatchItem(newRuns, newSlots, newTime);
          } else {
            batch.items.remove(tid);
          }

          return itemChanged;
        }
      }
    }

    return itemChanged;
  }

  void _assertValid(List<Batch> batches, {required bool noExcess, Schedule? schedule}) {
    final produced = <int, int>{};
    final consumed = <int, int>{};

    // assert that there is enough material to start each batch
    int batchIndex = 0;
    for (var batch in batches) {
      final producedThisBatch = <int, int>{};

      // what did we produce and consume this batch?
      batch.items.forEach((tid, item) {
        producedThisBatch[tid] = item.runs * SD.numProducedPerRun(tid);
        _problem!.dependencies[tid]?.forEach((cid, childPerParent) {
          assert(item.runs > 0);
          int numConsumed = getNumNeeded(item.runs, item.slots, childPerParent, _problem!.jobMaterialBonus[tid]!);
          consumed.update(cid, (value) => value + numConsumed, ifAbsent: () => numConsumed);
        });
      });

      // did we produce enough on previous batches to start this batch?
      consumed.forEach((cid, numConsumed) {
        assert(numConsumed > 0);
        assert(produced.containsKey(cid));
        final numProducedOnPrevBatches = produced[cid]!;
        if (numConsumed > numProducedOnPrevBatches) {
          print("InvalidSchedule batch:" +
              batchIndex.toString() +
              " noExcess:" +
              noExcess.toString() +
              " " +
              SD.enName(cid) +
              ' : ' +
              numConsumed.toString() +
              ' > ' +
              numProducedOnPrevBatches.toString());
          print(schedule?.toString() ?? '');
        }
        assert(numConsumed <= numProducedOnPrevBatches);
      });

      // add our production to the total
      producedThisBatch.forEach((tid, qty) {
        produced.update(tid, (value) => value + qty, ifAbsent: () => qty);
      });
    }

    // assert that the total amount produced is not more than a single run greater than the amount consumed (we make only as much as we use)
    consumed.forEach((cid, numConsumed) {
      assert(numConsumed > 0);
      assert(produced.containsKey(cid)); // if we are consuming it then we should have produced it
      final numProduced = produced[cid]!;
      assert(numProduced >= numConsumed); // basic fact that we need to produce at least what is consumed
      if (noExcess) {
        int numBuiltForSale = (_problem!.runsExcess[cid] ?? 0) * SD.numProducedPerRun(cid);
        if (numProduced - numBuiltForSale - numConsumed >= SD.numProducedPerRun(cid)) {
          print(' Too much excess: ${SD.enName(cid)} : ${numProduced - numBuiltForSale - numConsumed} >= ${SD.numProducedPerRun(cid)}');
        }
        assert(numProduced - numBuiltForSale - numConsumed < SD.numProducedPerRun(cid)); // we have minimized batch time and excess successfully
      }
    });
  }

  Map<int, int> _getExcess(List<Batch> batches) {
    // Calculate excess
    final Map<int, int> excess = {};
    for (var batch in batches) {
      batch.items.forEach((tid, item) {
        int numProduced = item.runs * SD.numProducedPerRun(tid);
        excess.update(tid, (value) => value + numProduced, ifAbsent: () => numProduced);
        _problem!.dependencies[tid]?.forEach((cid, childPerParent) {
          int numConsumed = getNumNeeded(item.runs, item.slots, childPerParent, _problem!.jobMaterialBonus[tid]!);
          excess.update(cid, (value) => value - numConsumed, ifAbsent: () => -numConsumed);
        });
      });
    }

    // Take runsExcess into consideration
    _problem!.runsExcess.forEach((tid, qty) {
      assert(excess.containsKey(tid));
      excess.update(tid, (v) => v - qty * SD.numProducedPerRun(tid));
    });

    // Apply inventory
    // TODO this should work with negative excess
    //for (var tid in excess.keys.toSet()) {
    //  if (_problem!.inventory.containsType(tid)) {
    //    excess[tid] = max(0, excess[tid]! - _problem!.inventory.get(tid));
    //  }
    //  if (excess[tid]! == 0) {
    //    excess.remove(tid);
    //  }
    //}

    return excess;
  }

  List<Batch> _getBatchesByTime(Schedule schedule) {
    var result = <Batch>[];
    int iRtn = 0;
    int iMfg = 0;
    for (bool notAtEnd = true; notAtEnd;) {
      notAtEnd = false;
      Fraction? rtnEndTime;
      if (schedule.machine2batches.containsKey(IndustryType.REACTION)) {
        var batches = schedule.machine2batches[IndustryType.REACTION]!;
        if (iRtn < batches.length) {
          rtnEndTime = batches[iRtn].startTime.toFraction() + batches[iRtn].getMaxTime();
          result.add(batches[iRtn]);
          iRtn += 1;
          notAtEnd = true;
        }
      }
      if (schedule.machine2batches.containsKey(IndustryType.MANUFACTURING)) {
        var batches = schedule.machine2batches[IndustryType.MANUFACTURING]!;
        while (iMfg < batches.length && (rtnEndTime == null || batches[iMfg].startTime < rtnEndTime.toDouble())) {
          result.add(batches[iMfg]);
          iMfg += 1;
          notAtEnd = true;
        }
      }
    }
    return result;
  }

  bool get isRunning => _currentWorker != null;

  Problem? _problem;
  Schedule? _schedule;

  Problem? getProblemSolved() => _problem;

  Schedule? getSchedule() => _schedule;
}

// AdvancedSolver implements ScheduleProvider -- desktop only
//   ExposeAdvancedSchedule
//      (set basic schedule as current if there is no adv schedule, then continue publishing adv schedules as discovered)
//      or
//      (set adv schedules as current as they are discovered if there is an adv schedule)
//      and notify
//
//   ExposeBasicSchedule
//      set basic schedule as current and notify
//
//   isRunning - is there an isolate doing a computation atm?
//
//   start
//   stop
