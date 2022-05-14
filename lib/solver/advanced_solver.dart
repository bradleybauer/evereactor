import 'dart:isolate';
import 'dart:math';

import 'package:EveIndy/industry.dart';
import 'package:EveIndy/math.dart';
import 'package:EveIndy/models/industry_type.dart';
import 'package:EveIndy/solver/basic_solver.dart';
import 'package:flutter/foundation.dart';
import 'package:fraction/fraction.dart';

import '../sde.dart';
import '../sde_extra.dart';
import 'problem.dart';
import 'schedule.dart';
import 'worker.dart';

/*
(ui isolate)     (msgr isolate)            (solver thread)
request start -> enters c++ event loop
                 starts                 -> stars solving
                 sleeps
                 ...
                 wakes                  <- solver thread provides schedule
                 returns to dart
                 gets sch (2c++)
updates ui    <- msgs ui of new sch
                 enters c++ event loop
                 sleeps
                 ...
                 wakes                  <- solver thread provides schedule
                 returns to dart
                 gets sch (2c++)
updates ui    <- msgs ui of new sch
                 enters c++ event loop
                 sleeps
                 ...
--------------------------------------------------------------------------------------
request stop  -> wakes
(2c++)           stops solver thread
                 returns to dart
                 Isolate.exit()
--------------------------------------------------------------------------------------
or
--------------------------------------------------------------------------------------
                 wakes                  <- solver finishes optimization
                 stops solver thread
                 returns to dart
                 Isolate.exit()
--------------------------------------------------------------------------------------
*/

class AdvancedSolver extends ChangeNotifier {
  Isolate? _currentWorker;

  // A port for listening for messages from the worker isolate
  final ReceivePort rp = ReceivePort();

  AdvancedSolver() {
    rp.listen(_handleReceiveMessage);
  }

  void _handleReceiveMessage(msg) {
    //print('in handle receive message');
    if (msg != null) {
      postProcessSchedule(msg!);
    } else {
      print('msg null!');
    }
    // else this is a stop message notify ui
    //notifyListeners();
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

    // TODO update batch start times

    final batchesByTime = _getBatchesByTime(schedule);
    Map<int, int> excess = _getExcess(batchesByTime);

    // the given schedule is valid
    _assertValid(batchesByTime, noExcess: false);

    // iterate through batches backwards in time and remove excess runs
    for (var batch in batchesByTime.reversed.toList()) {
      final machine = SDE.blueprints[batch.items.entries.first.key]!.industryType;
      // get an initial amount of children used then remove the excess runs
      bool nothingChanged = true;
      batch.items.entries.toList().forEach((e) {
        final tid = e.key;
        final item = e.value;
        if (excess.containsKey(tid)) {
          final excessRuns = (excess[tid]! / SD.numProducedPerRun(tid).toDouble()).floor();
          if (excess[tid]! < 0) {
            print('NEGATIVE EXCESS:' + excess[tid]!.toString() + '      excessRuns:' + excessRuns.toString() + '   oldER:' + (excess[tid]!~/SD.numProducedPerRun(tid)).toString());
          }
          if (excessRuns != 0) {
            nothingChanged = false;
            final newRuns = item.runs - excessRuns;
            if (newRuns > 0) {
              assert(item.slots >= 1);
              // BasicSolver.setOptimalLineAlloc will reset slots and time, so exact values here are not hugely important.
              // I could put BatchItem(newRuns, 1, timeOnOneSlot) into batch[tid] if I wanted but that could encourage the BasicSolver to produce
              // an alloc that is more different from the original alloc than it otherwise needs to be.
              int newSlots = min(newRuns, item.slots);
              Fraction newTime = ((ceilDiv(newRuns, newSlots) * SD.timePerRun(tid)).toFraction() * _problem!.jobTimeBonus[tid]!).reduce();
              batch[tid] = BatchItem(newRuns, newSlots, newTime);
            } else if (newRuns <= 0) {
              batch.items.remove(tid);
            }
          }
        }
      });

      // After excess runs of tid are removed from this batch, we have less (possibly zero) excess runs in the build if we change nothing else.
      // (we probably do change tings)
      // However, items in earlier batches may depend on tid and so if those batches are changed (runs alloc or #runs of parent of tid) then
      // the amount of tid required may increase which would mean that the excess could reduce. In the case we had zero excess, we could end up
      // with a deficit.
      //
      // I think the solution is to allow the excess map to take negative values and then use those to actually increase the number of runs of
      // tings if necessary.

      if (nothingChanged) {
        continue;
      }

      // after fixing the runs, reallocate runs to slots using BasicSolver
      if (batch.items.isNotEmpty) {
        // balance the lines
        BasicSolver.setOptimalLineAlloc(batch, machine, _problem!);
      } else {
        // Remove empty batches from the schedule
        print('Removing empty batch');
        schedule.machine2batches[machine]!.remove(batch);
        batchesByTime.remove(batch);
      }

      excess = _getExcess(batchesByTime);
    }

    // excess = _getExcess(batchesByTime);
    // final finalExcessLength = excess.length;
    // print('initial excess length:' + initialExessLength.toString() +'    final excess length:' + finalExcessLength.toString());
    // excess.forEach((key, value) {
    //   print(SD.enName(key) + ' : ' + value.toString() + '<' + SD.numProducedPerRun(key).toString());
    // });

    _assertValid(batchesByTime, noExcess: true);

    // TODO update batch start times
    // Compute new schedule time
    var maxEndingTime = 0.toFraction();
    for (var batch in batchesByTime) {
      final endTime = batch.getEndTime();
      maxEndingTime = endTime > maxEndingTime ? endTime : maxEndingTime;
    }
    print('time:' +
        (schedule.time / 3600.0).toStringAsFixed(2) +
        '   new: ' +
        maxEndingTime.toDouble().toString() +
        's     ' +
        (maxEndingTime.toDouble() / 3600.0).toStringAsFixed(2));
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
          print("InvalidSchedule noExcess:" +
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
          print(SD.enName(cid) +
              ' : ' +
              (numProduced - numBuiltForSale - numConsumed).toString() +
              ' >= ' +
              SD.numProducedPerRun(cid).toString());
        }
        assert(numProduced - numBuiltForSale - numConsumed < SD.numProducedPerRun(cid)); // we have minimized batch time and excess successfully
      }
    });
  }

  Map<int, int> _getExcess(List<Batch> batches) {
    // Calculate excess
    final Map<int, int> excess = {};
    int batchIndex = 0;
    for (var batch in batches) {
      batch.items.forEach((tid, item) {
        int numProduced = item.runs * SD.numProducedPerRun(tid);
        excess.update(tid, (value) => value + numProduced, ifAbsent: () => numProduced);
        _problem!.dependencies[tid]?.forEach((cid, childPerParent) {
          int numConsumed = getNumNeeded(item.runs, item.slots, childPerParent, _problem!.jobMaterialBonus[tid]!);
          excess.update(cid, (value) => value - numConsumed, ifAbsent: () => -numConsumed);
          if (excess[cid]! < 0) {
            print(SD.enName(cid) + ' has negative excess batch ' + batchIndex.toString() + '/' +batches.length.toString());
          }
        });
      });
      batchIndex += 1;
    }

    // Take runsExcess into consideration
    _problem!.runsExcess.forEach((tid, qty) {
      if (excess.containsKey(tid)) {
        excess.update(tid, (v) => v - qty * SD.numProducedPerRun(tid), ifAbsent: () => -qty * SD.numProducedPerRun(tid));
      }
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
