import 'package:EveIndy/misc.dart';
import 'package:fraction/fraction.dart';

import '../math.dart';
import '../models/industry_type.dart';
import '../sde_extra.dart';

class BatchItem {
  final int runs;
  final int slots;
  final Fraction time;

  BatchItem(this.runs, this.slots, Fraction time) : this.time = time.reduce();
}

class Batch {
  final Map<int, BatchItem> _items = {};

  Map<int, BatchItem> getItems() => _items;

  Iterable<int> getJobsOfMaxTime() {
    final maxT = getMaxTime();
    return _items.keys.where((tid) => _items[tid]!.time == maxT);
  }

  Iterable<int> getTypesWithTimeLessThan(Fraction time) =>
      _items.entries.where((e) => e.value.time < time).map((e) => e.key);

  Fraction getMaxTime() => _items.values.fold(0.toFraction(), (previousValue, e) {
        if (previousValue < e.time) {
          return e.time;
        }
        return previousValue;
      });

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
  final _machine2batches = <IndustryType, List<Batch>>{};
  double time = 0.0;

  void addBatches(IndustryType machine, List<Batch> batches) => _machine2batches[machine] = batches;

  Map<IndustryType,List<Batch>> getBatches() => _machine2batches;

//     for machine in sorted(schedule):
//         print()
//         print(machine)
//         for b, batch in enumerate(schedule[machine]):
//             t = 0
//             for k, (r, s, tt) in batch.items():
//                 t = max(t, tt)
//             print('Batch ', b, ' ', t / 3600)
//             for k, (r, s, tt) in sorted(batch.items()):
//                 print(k, '\tr:', r, '   \tl:', s, '\tt:', tt / 3600)
  @override
  String toString() {
    var str = "";
    for (IndustryType machine in _machine2batches.keys) {
      str += ('\n' + machine.toString() + '\n');
      Fraction b = 0.toFraction();
      for (var batch in _machine2batches[machine]!) {
        Fraction mt = batch.getMaxTime();
        str += ('Batch ' + b.toString() + ' ' + (mt / 3600.toFraction()).toDouble().toString() + '\n');
        for (int tid in batch.tids) {
          int runs = batch[tid].runs;
          int slots = batch[tid].slots;
          Fraction tt = batch[tid].time;
          String name = SD.enName(tid);
          str += ('\t' +
              name +
              ' ' * (60 - name.length) +
              'r:' +
              runs.toString() +
              (' ' * (10 - log10(runs).ceil())) +
              '\ts:' +
              slots.toString() +
              (' ' * (7 - log10(slots).ceil())) +
              '\tt:' +
              (tt / 3600.toFraction()).toDouble().toString() +
              '\n');
        }
        b += 1.toFraction();
      }
    }
    return str;
  }
}
