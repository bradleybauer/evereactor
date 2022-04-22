// TODO use integer math for all bonuses.

import 'dart:math';

import '../math.dart';
import '../models/industry_type.dart';
import '../models/inventory.dart';
import '../sde_extra.dart';
import 'problem.dart';
import 'schedule.dart';

const thirtyDays = 30 * 24 * 3600;

abstract class Approximator {
  // if there are more than 1000 batches, then the user has probably entered some stupid combination of settings
  static const MAX_NUM_BATCHES = 1000;

  /// Forms a batch using the [available] jobs where each job is scheduled on one line.
  static Batch _getBatch(Map<int, int> available, IndustryType machine, Problem prob) {
    final batch = Batch();
    int slotsUsedOnBatch = 0;
    for (int tid in available.keys) {
      // what is the maximum number of slots we have remaining on this batch
      final slotsAvailable = min(prob.maxNumSlotsOfMachine[machine]! - slotsUsedOnBatch, prob.maxNumSlotsOfJob[tid]!);

      if (slotsAvailable == 0) {
        break;
      }

      // number of units of this item needed by items built so far
      final numUnits = available[tid]!;

      // number of runs needed
      int runs = ceilDiv(numUnits, SD.numProducedPerRun(tid));

      // can not have more than this number of runs on a slot due to 30 day constraint
      int maxNumRunsPerSlot = (thirtyDays / (SD.timePerRun(tid) * prob.jobTimeBonus[tid]!)).ceil();

      // can not have more runs on a slot than the user requested max
      maxNumRunsPerSlot = min(maxNumRunsPerSlot, prob.maxNumRunsPerSlotOfJob[tid]!);

      // runs can be no more than what would fill the number of slots available given a max num runs per slot
      runs = min(runs, slotsAvailable * maxNumRunsPerSlot);

      // get number of slots used
      final slotsUsedForJob = ceilDiv(runs, maxNumRunsPerSlot);

      assert(slotsUsedOnBatch + slotsUsedForJob <= prob.maxNumSlotsOfMachine[machine]!);
      // if (slotsUsedOnBatch + slotsUsedForJob > prob.maxNumSlotsOfMachine[machine]!) {
      //   break;
      // }

      batch[tid] = BatchItem(
        runs,
        slotsUsedForJob,
        SD.baseTime(runs, slotsUsedForJob, SD.timePerRun(tid)) * prob.jobTimeBonus[tid]!,
      );
      slotsUsedOnBatch += slotsUsedForJob;
    }
    return batch;
  }

  static Map<int, int> _getBatchDependencies(Batch batch, IndustryType machine, Problem prob) {
    Map<int, int> batchDependencies = <int, int>{};
    for (int tid in batch.tids) {
      int runs = batch[tid].runs;
      int slots = batch[tid].slots;
      if (prob.dependencies.containsKey(tid)) {
        final int remainder = runs % slots;
        final int runsFloor = runs ~/ slots;
        final int runsCeil = runsFloor + 1;
        prob.dependencies[tid]!.forEach((int child, int childPerParent) {
          // TODO integer math
          int needed =
              (childPerParent * runsFloor * prob.jobMaterialBonus[tid]! - .000001).ceil() * (slots - remainder);
          needed += (childPerParent * runsCeil * prob.jobMaterialBonus[tid]! - .000001).ceil() * remainder;
          batchDependencies.update(child, (value) => value + needed, ifAbsent: () => needed);
        });
      }
    }
    return batchDependencies;
  }

  // Maximize the minimum job time on the batch.
  // If maxT is less than 30 days then the output schedule will have a maxT of less than 30 days.
  // So this function does not violate the 'runs cannot start after 30 days' constraint.
  // This function does not increase the number of slots a job is ran on.
  static void _maximizeMinTime(Batch batch, IndustryType machine, Problem prob) {
    final maxT = batch.getMaxTime();
    final types = batch.getTypesWithTimeLessThan(maxT);
    for (int tid in types) {
      int runs = batch[tid].runs;
      int slots = batch[tid].slots;
      double timePerRun = SD.timePerRun(tid) * prob.jobTimeBonus[tid]!;
      int newMaxRunsPerSlot = (maxT / timePerRun).floor();
      // can not queue up more than 30 days worth of runs on one slot.
      newMaxRunsPerSlot = min(newMaxRunsPerSlot, (thirtyDays / timePerRun).ceil());
      int newNumSlots = ceilDiv(runs, newMaxRunsPerSlot);
      double newTime = SD.baseTime(runs, newNumSlots, SD.timePerRun(tid)) * prob.jobTimeBonus[tid]!;
      assert(newTime - SD.timePerRun(tid) <= thirtyDays);
      assert(newNumSlots <= slots);
      batch[tid] = BatchItem(
        runs,
        newNumSlots,
        newTime,
      );
    }
    // newMaxT = util.getMaxTimeOfBatch(batch)
    // assert (newMaxT == maxT)
  }

  // Add slots, one at a time, to the jobs of max time to minimize the max time.
  // Doing it this way ensures that the minimum time is still maximized.
  // This function strictly increases the number of slots for each job.
  // So if the input batch does not violate the 30 day constraint then the output
  // batch also will not violate the 30 day constraint.
  static void _minimizeMaxTimeUsingSpareSlots(Batch batch, IndustryType machine, Problem prob) {
    final numSlots = batch.getNumSlots();
    if (numSlots < prob.maxNumSlotsOfMachine[machine]!) {
      int s = prob.maxNumSlotsOfMachine[machine]! - numSlots;
      while (s > 0) {
        Iterable<int> P = batch.getJobsOfMaxTime();
        if (s < P.length) {
          break;
        }
        var didChangeSlots = false;
        for (int tid in P) {
          int runs = batch[tid].runs;
          int slots = batch[tid].slots;
          if (slots + 1 <= min(min(prob.maxNumSlotsOfJob[tid]!, prob.maxNumSlotsOfMachine[machine]!), runs)) {
            didChangeSlots = true;
            slots += 1;
            batch[tid] = BatchItem(
              runs,
              slots,
              SD.baseTime(runs, slots, SD.timePerRun(tid)) * prob.jobTimeBonus[tid]!,
            );
            s -= 1;
            if (s == 0) {
              break;
            }
          }
        }
        if (!didChangeSlots) {
          break;
        }
      }
    }
  }

  /// If possible, reduce the amount of slots used by a job without increasing the maximum batch time.
  static void _minimizeSlotsWithoutIncreasingMaxTime(Batch batch, IndustryType machine, Problem prob) {
    double maxT = batch.getMaxTime();
    assert(maxT - SD.timePerRun(batch.getTidOfMaxTime()) <= thirtyDays);
    for (int tid in batch.tids) {
      int runs = batch[tid].runs;
      int slots = batch[tid].slots;
      double time = batch[tid].time;
      assert(time - SD.timePerRun(tid) <= thirtyDays);
      while (slots > 1) {
        double newT = SD.baseTime(runs, slots - 1, SD.timePerRun(tid)) * prob.jobTimeBonus[tid]!;
        // cannot use more runs per line than user request
        final maxNumRunsPerSlot = ceilDiv(runs, slots - 1);
        if (newT <= maxT &&
            newT - SD.timePerRun(tid) <= thirtyDays &&
            maxNumRunsPerSlot <= prob.maxNumRunsPerSlotOfJob[tid]!) {
          slots -= 1;
          time = newT;
        } else {
          break;
        }
      }
      batch[tid] = BatchItem(runs, slots, time);
    }
  }

  static void _updateNeededUsingProduced(Batch batch, Map<int, int> needed) {
    for (int tid in batch.tids) {
      if (needed.containsKey(tid)) {
        int numNeeded = needed[tid]!;
        int numProduced = batch[tid].runs * SD.numProducedPerRun(tid);
        needed[tid] = max(0, numNeeded - numProduced);
        if (needed[tid] == 0) {
          needed.remove(tid);
        }
      }
    }
  }

  static void _updateNeededUsingConsumed(
      Batch batch, Map<int, int> needed, IndustryType machine, Problem prob, Inventory inventoryCopy) {
    // how much did we consume with this batch?
    final batchDependencies = _getBatchDependencies(batch, machine, prob);
    batchDependencies.forEach((tid, deps) {
      if (inventoryCopy.containsType(tid)) {
        // can use the inventory instead of requesting earlier batches to build
        deps = inventoryCopy.useQuantity(tid, deps);
      }
      if (deps > 0) {
        needed.update(tid, (value) => value + deps, ifAbsent: () => deps);
      }
      if (needed.containsKey(tid) && needed[tid] == 0) {
        needed.remove(tid);
      }
    });
  }

  static void _setOptimalLineAlloc(Batch batch, IndustryType machine, Problem prob) {
    _maximizeMinTime(batch, machine, prob);
    _minimizeMaxTimeUsingSpareSlots(batch, machine, prob);
    _minimizeSlotsWithoutIncreasingMaxTime(batch, machine, prob);
  }

  static Map<int, int> _getNumProducedFromRuns(Map<int, int> tid2runs) {
    final tid2numProduced = {...tid2runs};
    for (int tid in tid2numProduced.keys) {
      tid2numProduced.update(tid, (value) => value * SD.numProducedPerRun(tid));
    }
    return tid2numProduced;
  }

  static Schedule get(Problem prob) {
    Map<int, int> needed = _getNumProducedFromRuns(prob.runsExcess);
    Inventory inventoryCopy = Inventory.cloneOf(prob.inventory);
    final schedule = Schedule();
    for (var machine in [IndustryType.MANUFACTURING, IndustryType.REACTION]) {
      // Schedule manufacturing first, if possible
      if (!prob.machines.contains(machine)) {
        continue;
      }
      final batches = <Batch>[];
      Map<int, int> neededOfMachineType =
          Map.fromEntries(needed.entries.where((entry) => prob.job2machine[entry.key]! == machine));
      while (neededOfMachineType.isNotEmpty) {
        final batch = _getBatch(neededOfMachineType, machine, prob);
        _setOptimalLineAlloc(batch, machine, prob);
        batches.insert(0, batch);

        // sanity check
        if (batches.length > MAX_NUM_BATCHES) {
          // TODO handle error here
          return Schedule();
        }

        _updateNeededUsingProduced(batch, needed);
        _updateNeededUsingConsumed(batch, needed, machine, prob, inventoryCopy);

        neededOfMachineType = Map.fromEntries(needed.entries.where((entry) => prob.job2machine[entry.key]! == machine));
      }
      // for (Batch batch in batches) { // TODO need this here?
      //   _minimizeSlotsWithoutIncreasingMaxTime(batch, machine, prob);
      // }

      schedule.addBatches(machine, batches);

      // TODO need a more accurate way to get minimum schedule time here
      if (prob.M2DependsOnM1) {
        schedule.time += Batch.getTimeForBatches(batches);
      } else {
        schedule.time = max(schedule.time, Batch.getTimeForBatches(batches));
      }
    }
    return schedule;
  }
}
