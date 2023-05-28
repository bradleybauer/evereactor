import 'dart:math';

import 'package:fraction/fraction.dart';

import '../models/industry_type.dart';
import '../sde.dart';
import '../sde_extra.dart';
import '../strings.dart';

class BatchItem {
  final int runs;
  final int slots;
  final Fraction time;

  BatchItem(this.runs, this.slots, Fraction time) : time = time.reduce();
}

class Batch {
  final Map<int, BatchItem> _items = {};
  int startTime = 0;

  Map<int, BatchItem> getItems() => _items;

  Iterable<int> getJobsOfMaxTime() {
    final maxT = getMaxTime();
    return _items.keys.where((tid) => _items[tid]!.time == maxT);
  }

  Iterable<int> getTypesWithTimeLessThan(Fraction time) => _items.entries.where((e) => e.value.time < time).map((e) => e.key);

  Fraction getMaxTime() => _items.values.fold(0.toFraction(), (previousValue, e) {
        if (previousValue < e.time) {
          return e.time;
        }
        return previousValue;
      });

  Fraction getEndTime() {
    return startTime.toFraction() + getMaxTime();
  }

  int getTidOfMaxTime() {
    Fraction maxTime = 0.toFraction();
    int tid = -1;
    for (var entry in _items.entries) {
      if (entry.value.time > maxTime) {
        tid = entry.key;
        maxTime = entry.value.time;
      }
    }
    return tid;
  }

  int getNumSlots() => _items.values.fold(0, (previousValue, e) => previousValue + e.slots);

  Iterable<int> get tids => _items.keys;

  Iterable<MapEntry<int, BatchItem>> get entries => _items.entries;

  Map<int, BatchItem> get items => _items;

  operator [](int i) => _items[i]!;

  operator []=(int i, BatchItem value) => _items[i] = value;

  static double getTimeForBatches(List<Batch> batches) =>
      batches.fold(0.0, (double previousValue, batch) => previousValue.toDouble() + batch.getMaxTime().toDouble());
}

class Schedule {
  Map<IndustryType, List<Batch>> machine2batches;
  double time = 0.0;
  bool isOptimal = false;
  bool isInfeasible = false;
  bool isOptimized = false;

  Schedule(this.machine2batches);

  Schedule.empty() : machine2batches = {};

  void addBatches(IndustryType machine, List<Batch> batches) => machine2batches[machine] = batches;

  Map<IndustryType, List<Batch>> getBatches() => machine2batches;

  Map<int, int> getNumBlueprintsNeeded() {
    final result = <int, int>{};
    for (var batches in machine2batches.values) {
      for (var batch in batches) {
        batch.items.forEach((tid, item) {
          result.update(tid, (value) => max(item.slots, value), ifAbsent: () => item.slots);
        });
      }
    }
    return result;
  }

  @override
  String toString() {
    if (machine2batches.isEmpty) {
      return "";
    }
    var str = ",Item,Runs,Lines,Runs/Line,Remainder\n";
    for (final machine in [IndustryType.REACTION, IndustryType.MANUFACTURING]) {
      if (!machine2batches.containsKey(machine)) {
        continue;
      }
      final machineStr = machine == IndustryType.MANUFACTURING ? 'Manufacturing' : 'Reactions';
      int b = 1;
      for (var batch in machine2batches[machine]!) {
        var tids = [...batch.tids];
        tids.sort((a, b) {
          final comp = SDE.items[b]!.groupID.compareTo(SDE.items[a]!.groupID);
          if (comp == 0) {
            return SD.enName(a).compareTo(SD.enName(b));
          }
          return comp;
        });
        Fraction mt = batch.getMaxTime();
        str += '$machineStr Batch:$b Start:${(batch.startTime / 3600.0).toStringAsFixed(1)} End:${(batch.startTime / 3600.0 + (mt / 3600.toFraction()).toDouble()).toDouble().toStringAsFixed(1)}\n';
        for (int tid in tids) {
          int runs = batch[tid].runs;
          int slots = batch[tid].slots;
          String name = Strings.get(SDE.items[tid]!.nameLocalizations);
          str += ',$name,$runs,$slots,${runs ~/ slots},${(runs % slots) == 0 ? "" : (runs % slots).toString()}\n';
        }
        str += "\n";
        b += 1;
      }
    }
    return str.replaceAll(',', '\t');
  }
}
