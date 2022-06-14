import 'dart:math';

import 'package:fraction/fraction.dart';

import '../math.dart';
import '../models/industry_type.dart';
import '../models/inventory.dart';
import '../sde_extra.dart';
import 'problem.dart';
import 'schedule.dart';

const thirtyDays = 30 * 24 * 3600;

abstract class BasicSolver {
  // if there are more than 100 batches, then the user has probably entered some bad combination of settings
  static const MAX_NUM_BATCHES = 100;

  static Schedule? getSchedule(Problem prob) {
    if (prob.runsExcess.isEmpty) {
      return Schedule.empty();
    }
    Map<int, int> needed = _getNumProducedFromRuns(prob.runsExcess);
    Inventory inventoryCopy = Inventory.cloneOf(prob.inventory);
    final schedule = Schedule.empty();
    for (var machine in [IndustryType.MANUFACTURING, IndustryType.REACTION]) {
      // Schedule manufacturing first, if possible
      if (!prob.machines.contains(machine)) {
        continue;
      }
      final batches = <Batch>[];
      Map<int, int> neededOfMachineType = Map.fromEntries(needed.entries.where((entry) => prob.job2machine[entry.key]! == machine));
      while (neededOfMachineType.isNotEmpty) {
        final batch = _getBatch(neededOfMachineType, machine, prob);
        setOptimalLineAlloc(batch, machine, prob);
        batches.insert(0, batch);

        // sanity check
        if (batches.length > MAX_NUM_BATCHES) {
          return null;
        }

        _updateNeededUsingProduced(batch, needed);
        _updateNeededUsingConsumed(batch, needed, machine, prob, inventoryCopy);

        neededOfMachineType = Map.fromEntries(needed.entries.where((entry) => prob.job2machine[entry.key]! == machine));
      }

      schedule.addBatches(machine, batches);
    }

    // calculate batch start times and schedule time
    for (final machineType in [IndustryType.REACTION, IndustryType.MANUFACTURING]) {
      double machineTime = 0.0;
      if (schedule.machine2batches.containsKey(machineType)) {
        final batches = schedule.machine2batches[machineType]!;
        if (prob.M2DependsOnM1) {
          batches[0].startTime = schedule.time.toInt();
        } else {
          batches[0].startTime = 0;
        }
        for (int i = 1; i < batches.length; ++i) {
          batches[i].startTime = batches[i - 1].startTime + batches[i - 1].getMaxTime().toDouble().toInt();
        }
        machineTime = Batch.getTimeForBatches(batches);
      }
      if (prob.M2DependsOnM1) {
        schedule.time += machineTime;
      } else {
        schedule.time = max(schedule.time, machineTime);
      }
    }

    return schedule;
  }

  static Map<int, int> _getNumProducedFromRuns(Map<int, int> tid2runs) {
    final tid2numProduced = {...tid2runs};
    for (int tid in tid2numProduced.keys) {
      tid2numProduced.update(tid, (value) => value * SD.numProducedPerRun(tid));
    }
    return tid2numProduced;
  }

  /// Forms a batch using the [available] jobs where each job is scheduled on one line.
  static Batch _getBatch(Map<int, int> available, IndustryType machine, Problem prob) {
    final batch = Batch();
    int slotsUsedOnBatch = 0;
    final jobs = available.entries.toList();
    for (final entry in jobs) {
      final tid = entry.key;
      // what is the maximum number of slots we have remaining on this batch
      final slotsAvailable = min(prob.maxNumSlotsOfMachine[machine]! - slotsUsedOnBatch, prob.maxNumSlotsOfJob[tid]!);

      if (slotsAvailable == 0) {
        break;
      }

      // number of units of this item needed by items built so far
      //final numUnits = available[tid]!;
      final numUnits = entry.value;

      // number of runs needed
      int runs = ceilDiv(numUnits, SD.numProducedPerRun(tid));

      // can not have more than this number of runs on a slot due to 30 day constraint
      // int maxNumRunsPerSlot = (thirtyDays / (SD.timePerRun(tid) * prob.jobTimeBonus[tid]!)).ceil();

      // int maxTime = 48 * 3600 - 2 * 3600; // TODO ... this probalby will only work on desktop
      int maxTime = thirtyDays;

      // thirtyDays / (base * bonus)
      int maxNumRunsPerSlot = ceilDiv(maxTime * prob.jobTimeBonus[tid]!.denominator, SD.timePerRun(tid) * prob.jobTimeBonus[tid]!.numerator);

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
        // SD.baseTime(runs, slotsUsedForJob, SD.timePerRun(tid)) * prob.jobTimeBonus[tid]!,
        SD.baseTime(runs, slotsUsedForJob, SD.timePerRun(tid)).toFraction() * prob.jobTimeBonus[tid]!,
      );
      slotsUsedOnBatch += slotsUsedForJob;
    }
    return batch;
  }

  static void setOptimalLineAlloc(Batch batch, IndustryType machine, Problem prob) {
    _maximizeMinTime(batch, prob);
    _minimizeMaxTimeUsingSpareSlots(batch, machine, prob);
    _minimizeSlotsWithoutIncreasingMaxTime(batch, machine, prob);
  }

  // Maximize the minimum job time on the batch.
  // If maxT is less than 30 days then the output schedule will have a maxT of less than 30 days.
  // So this function does not violate the 'runs cannot start after 30 days' constraint.
  // This function does not increase the number of slots a job is ran on.
  static void _maximizeMinTime(Batch batch, Problem prob) {
    final maxT = batch.getMaxTime();
    final types = batch.getTypesWithTimeLessThan(maxT);
    for (int tid in types) {
      int runs = batch[tid].runs;
      int slots = batch[tid].slots;
      Fraction timePerRun = (SD.timePerRun(tid).toFraction() * prob.jobTimeBonus[tid]!).reduce();

      // Unfortunately have to reduce precision here. Using Fraction has repeatedly led to div by zero exceptions.
      int newMaxRunsPerSlot = maxT.toDouble() ~/ timePerRun.toDouble();

      // can not queue up more than 30 days worth of runs on one slot.
      // newMaxRunsPerSlot = min(newMaxRunsPerSlot, ceilDiv(thirtyDays * timePerRun.denominator, timePerRun.numerator));
      final tmp2 = Fraction(thirtyDays, timePerRun.numerator).reduce();
      newMaxRunsPerSlot = min(newMaxRunsPerSlot, ceilDiv(tmp2.numerator * timePerRun.denominator, tmp2.denominator));
      newMaxRunsPerSlot = min(newMaxRunsPerSlot, prob.maxNumRunsPerSlotOfJob[tid]!);
      //print('hai, r:' + runs.toString() + ' maxT:' + maxT.toDouble().toString() + '     tpr:' + timePerRun.toDouble().toString() + ' nmrps:' + newMaxRunsPerSlot.toString());
      int newNumSlots = ceilDiv(runs, newMaxRunsPerSlot);
      //print('bye nns:' + newNumSlots.toString() + ' ns:' + slots.toString());
      // double newTime = SD.baseTime(runs, newNumSlots, SD.timePerRun(tid)) * prob.jobTimeBonus[tid]!;
      Fraction newTime = SD.baseTime(runs, newNumSlots, SD.timePerRun(tid)).toFraction() * prob.jobTimeBonus[tid]!;
      assert((newTime - SD.timePerRun(tid).toFraction()) <= thirtyDays.toFraction());
      assert(newNumSlots <= slots);
      batch[tid] = BatchItem(
        runs,
        newNumSlots,
        newTime,
      );
    }
    // final newMaxT = batch.getMaxTime();
    // assert (newMaxT == maxT);
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
              // SD.baseTime(runs, slots, SD.timePerRun(tid)) * prob.jobTimeBonus[tid]!,
              SD.baseTime(runs, slots, SD.timePerRun(tid)).toFraction() * prob.jobTimeBonus[tid]!,
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
    Fraction maxT = batch.getMaxTime();
    assert(maxT - SD.timePerRun(batch.getTidOfMaxTime()).toFraction() <= thirtyDays.toFraction());
    for (int tid in batch.tids) {
      int runs = batch[tid].runs;
      int slots = batch[tid].slots;
      Fraction time = batch[tid].time;
      assert(time - SD.timePerRun(tid).toFraction() <= thirtyDays.toFraction());
      while (slots > 1) {
        Fraction newT = SD.baseTime(runs, slots - 1, SD.timePerRun(tid)).toFraction() * prob.jobTimeBonus[tid]!;
        // cannot use more runs per line than user request
        final maxNumRunsPerSlot = ceilDiv(runs, slots - 1);
        if (newT <= maxT &&
            newT - SD.timePerRun(tid).toFraction() <= thirtyDays.toFraction() &&
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

  static void _updateNeededUsingConsumed(Batch batch, Map<int, int> needed, IndustryType machine, Problem prob, Inventory inventoryCopy) {
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
          int needed = max(runsFloor,
                  ceilDiv(childPerParent * runsFloor * prob.jobMaterialBonus[tid]!.numerator, prob.jobMaterialBonus[tid]!.denominator)) *
              (slots - remainder);
          needed += max(runsCeil,
                  ceilDiv(childPerParent * runsCeil * prob.jobMaterialBonus[tid]!.numerator, prob.jobMaterialBonus[tid]!.denominator)) *
              remainder;
          batchDependencies.update(child, (value) => value + needed, ifAbsent: () => needed);
        });
      }
    }
    return batchDependencies;
  }
}
