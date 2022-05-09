import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:fraction/fraction.dart';

import '../models/industry_type.dart';
import 'ffi_types.dart';
import 'problem.dart';
import 'schedule.dart';

Fraction ffi2dart_fraction(FfiFraction frac) => Fraction(frac.numerator, frac.denominator);

BatchItem ffi2dart_batchItem(batchItem item) {
  final time = ffi2dart_fraction(item.time);
  return BatchItem(item.runs, item.slots, time);
}

Batch ffi2dart_batch(batch element) {
  final result = Batch();
  for (int i = 0; i < element.size; ++i) {
    final entry = element.entries
        .elementAt(i)
        .ref;
    result[entry.key] = ffi2dart_batchItem(entry.value);
  }
  return result;
}

List<Batch> ffi2dart_batchlist(batchList element) {
  final result = <Batch>[];
  for (int i = 0; i < element.size; ++i) {
    result.add(ffi2dart_batch(element.entries
        .elementAt(i)
        .ref));
  }
  return result;
}

Map<IndustryType, List<Batch>> ffi2dart_machine2batches(k2batches element) {
  final result = <IndustryType, List<Batch>>{};
  for (int i = 0; i < element.size; ++i) {
    final entry = element.entries
        .elementAt(i)
        .ref;
    final key = entry.key == 1 ? IndustryType.MANUFACTURING : IndustryType.REACTION;
    result[key] = ffi2dart_batchlist(entry.value);
  }
  return result;
}

// We use this to parse schedules passed to us from c++
Schedule ffi2dart_schedule(FfiSchedule schedule) {
  Schedule result = Schedule(ffi2dart_machine2batches(schedule.machine2batches));
  result.time = schedule.time;
  result.isOptimized = true;
  return result;
}

void make_fraction(FfiFraction frac, Fraction data) {
  frac.numerator = data.numerator;
  frac.denominator = data.denominator;
}

void make_batchItem(batchItem item, BatchItem data) {
  make_fraction(item.time, data.time);
  item.slots = data.slots;
  item.runs = data.runs;
}

void make_batch(batch b, Batch data) {
  b.size = data.items.length;
  b.entries = calloc.allocate(sizeOf<i2batchItemEntry>() * data.items.length);
  int i = 0;
  for (int key in data.items.keys) {
    final entry = b.entries
        .elementAt(i)
        .ref;
    entry.key = key;
    make_batchItem(entry.value, data.items[key]!);
    i += 1;
  }
}

void make_batchList(batchList element, List<Batch> data) {
  element.size = data.length;
  element.entries = calloc.allocate(sizeOf<batch>() * data.length);
  for (int i = 0; i < data.length; ++i) {
    final entry = element.entries
        .elementAt(i)
        .ref;
    make_batch(entry, data[i]);
  }
}

void make_k2batches(k2batches element, Map<IndustryType, List<Batch>> data) {
  element.size = data.length;
  element.entries = calloc.allocate(sizeOf<k2batchesEntry>() * data.length);
  int i = 0;
  for (final machine in data.keys) {
    final entry = element.entries
        .elementAt(i)
        .ref;
    entry.key = machine == IndustryType.MANUFACTURING ? 1 : 0;
    make_batchList(entry.value, data[machine]!);
    i += 1;
  }
}

Pointer<FfiSchedule> make_schedule(Schedule schedule) {
  final result = calloc<FfiSchedule>();
  result.ref.time = schedule.time;
  make_k2batches(result.ref.machine2batches, schedule.getBatches());
  return result;
}

void destroy_batch(batch b) => calloc.free(b.entries);

void destroy_batchList(batchList element) {
  for (int i = 0; i < element.size; ++i) {
    final entry = element.entries
        .elementAt(i)
        .ref;
    destroy_batch(entry);
  }
  calloc.free(element.entries);
}

void destroy_k2batches(k2batches element) {
  for (int i = 0; i < element.size; ++i) {
    final entry = element.entries
        .elementAt(i)
        .ref;
    destroy_batchList(entry.value);
  }
  calloc.free(element.entries);
}

void destroy_schedule(Pointer<FfiSchedule> schedule) {
  destroy_k2batches(schedule.ref.machine2batches);
  calloc.free(schedule);
}

void make_i2frac(i2frac element, Map<int, Fraction> data) {
  element.size = data.length;
  element.entries = calloc.allocate(sizeOf<i2fracEntry>() * data.length);
  int i = 0;
  for (var key in data.keys) {
    final entry = element.entries
        .elementAt(i)
        .ref;
    entry.key = key;
    make_fraction(entry.value, data[key]!);
    i += 1;
  }
}

void make_i2i(i2i element, Map<int, int> data) {
  element.size = data.length;
  element.entries = calloc.allocate(sizeOf<i2iEntry>() * data.length);
  int i = 0;
  for (var key in data.keys) {
    final entry = element.entries
        .elementAt(i)
        .ref;
    entry.key = key;
    entry.value = data[key]!;
    i += 1;
  }
}

void make_i2i2i(i2i2i element, Map<int, Map<int, int>> data) {
  element.size = data.length;
  element.entries = calloc.allocate(sizeOf<i2i2iEntry>() * data.length);
  int i = 0;
  for (var key in data.keys) {
    final entry = element.entries
        .elementAt(i)
        .ref;
    entry.key = key;
    make_i2i(entry.value, data[key]!);
    i += 1;
  }
}

Pointer<Int32> make_ilist(List<int> data) {
  final result = calloc.allocate(sizeOf<Int32>() * data.length).cast<Int32>();
  for (int i = 0; i < data.length; ++i) {
    result
        .elementAt(i)
        .value = data[i];
  }
  return result;
}

void destroy_i2frac(i2frac element) => calloc.free(element.entries);

void destroy_i2i(i2i element) => calloc.free(element.entries);

void destroy_i2i2i(i2i2i element) {
  for (int i = 0; i < element.size; ++i) {
    final entry = element.entries
        .elementAt(i)
        .ref;
    destroy_i2i(entry.value);
  }
  calloc.free(element.entries);
}

void destroy_ilist(Pointer<Int32> ptr) {
  calloc.free(ptr);
}

Pointer<FfiProblem> make_problem(Problem problem) {
  final result = calloc<FfiProblem>();
  make_i2i(result.ref.timePerRun, problem.timePerRun);
  make_i2i(result.ref.madePerRun, problem.madePerRun);
  make_i2i(result.ref.inventory, problem.inventory.getQuantities());
  make_i2i(result.ref.maxNumRunsPerSlotOfJob, problem.maxNumRunsPerSlotOfJob);
  make_i2i(
      result.ref.maxNumSlotsOfMachine,
      problem.maxNumSlotsOfMachine
          .map((k, v) => MapEntry(k == IndustryType.MANUFACTURING ? 1 : 0, v)));
  make_i2i(result.ref.maxNumSlotsOfJob, problem.maxNumSlotsOfJob);
  make_i2i(result.ref.runsExcess, problem.runsExcess);
  make_i2i(result.ref.job2machine,
      problem.job2machine.map((k, v) => MapEntry(k, v == IndustryType.MANUFACTURING ? 1 : 0)));
  result.ref.tids = make_ilist(problem.tids.toList());
  result.ref.float2int = problem.float2int;
  make_i2i2i(result.ref.dependencies, problem.dependencies);
  if (problem.approximation != null) {
    result.ref.approximation = make_schedule(problem.approximation!);
  }
  make_i2frac(result.ref.materialBonus, problem.jobMaterialBonus);
  make_i2frac(result.ref.timeBonus, problem.jobTimeBonus);
  return result;
}

void destroy_problem(Pointer<FfiProblem> p) {
  destroy_i2i(p.ref.timePerRun);
  destroy_i2i(p.ref.madePerRun);
  destroy_i2i(p.ref.inventory);
  destroy_i2i(p.ref.maxNumRunsPerSlotOfJob);
  destroy_i2i(p.ref.maxNumSlotsOfMachine);
  destroy_i2i(p.ref.maxNumSlotsOfJob);
  destroy_i2i(p.ref.runsExcess);
  destroy_i2i(p.ref.job2machine);
  destroy_ilist(p.ref.tids);
  destroy_i2i2i(p.ref.dependencies);
  if (p.ref.approximation.address != 0) {
    destroy_schedule(p.ref.approximation);
  }
  destroy_i2frac(p.ref.materialBonus);
  destroy_i2frac(p.ref.timeBonus);
  calloc.free(p);
}

