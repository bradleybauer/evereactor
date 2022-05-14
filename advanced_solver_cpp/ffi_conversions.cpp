#include "ffi_types.h"
#include "problem.h"
#include "schedule.h"

// we are passed a schedule & problem thru ffi and need to convert it
Fraction ffi2cpp_fraction(FfiFraction frac) { return Fraction(frac.numerator, frac.denominator); }

BatchItem ffi2cpp_batchItem(batchItem& item) {
  auto time = ffi2cpp_fraction(item.time);
  return BatchItem(item.runs, item.slots, time);
}

Batch ffi2cpp_batch(batch& element) {
  auto result = Batch();
  for (int i = 0; i < element.size; ++i) {
    auto& entry = element.entries[i];
    result.items[entry.key] = ffi2cpp_batchItem(entry.value);
  }
  return result;
}

vector<Batch> ffi2cpp_batchlist(batchList element) {
  auto result = vector<Batch>{};
  for (int i = 0; i < element.size; ++i) {
    result.push_back(ffi2cpp_batch(element.entries[i]));
  }
  return result;
}

map<IndustryType, vector<Batch>> ffi2cpp_machine2batches(k2batches& element) {
  auto result = map<IndustryType, vector<Batch>>{};
  for (int i = 0; i < element.size; ++i) {
    auto& entry = element.entries[i];
    auto key = entry.key == MachineType::MANUFACTURING_ ? IndustryType::MANUFACTURING : IndustryType::REACTION;
    result[key] = ffi2cpp_batchlist(entry.value);
  }
  return result;
}

Schedule ffi2cpp_schedule(FfiSchedule schedule) {
  Schedule result = Schedule();
  result.machine2batches = ffi2cpp_machine2batches(schedule.machine2batches);
  result.time = schedule.time;
  return result;
}

map<int, int64_t> ffi2cpp_i2i(i2i& element) {
  auto result = map<int, int64_t>{};
  for (int i = 0; i < element.size; ++i) {
    auto& entry = element.entries[i];
    result[entry.key] = entry.value;
  }
  return result;
}

map<int, map<int, int64_t>> ffi2cpp_i2i2i(i2i2i& element) {
  auto result = map<int, map<int, int64_t>>{};
  for (int i = 0; i < element.size; ++i) {
    auto& entry = element.entries[i];
    result[entry.key] = ffi2cpp_i2i(entry.value);
  }
  return result;
}

map<int, Fraction> ffi2cpp_i2frac(i2frac& element) {
  auto result = map<int, Fraction>{};
  for (int i = 0; i < element.size; ++i) {
    auto& entry = element.entries[i];
    result[entry.key] = ffi2cpp_fraction(entry.value);
  }
  return result;
}

map<int, IndustryType> ffi2cpp_i2indy(i2i& element) {
  auto result = map<int, IndustryType>{};
  for (int i = 0; i < element.size; ++i) {
    auto& entry = element.entries[i];
    result[entry.key] = entry.value == 0 ? IndustryType::REACTION : IndustryType::MANUFACTURING;
  }
  return result;
}

map<IndustryType, int64_t> ffi2cpp_indy2i(i2i& element) {
  auto result = map<IndustryType, int64_t>{};
  for (int i = 0; i < element.size; ++i) {
    auto& entry = element.entries[i];
    result[entry.key == 0 ? IndustryType::REACTION : IndustryType::MANUFACTURING] = entry.value;
  }
  return result;
}

Problem ffi2cpp_problem(struct FfiProblem p) {
  // clang-format off
  return Problem(ffi2cpp_i2i(p.runsExcess),
                 ffi2cpp_i2i(p.madePerRun),
                 ffi2cpp_i2i(p.timePerRun),
                 ffi2cpp_i2indy(p.job2machine),
                 ffi2cpp_i2i2i(p.dependencies),
                 ffi2cpp_i2i(p.inventory),
                 ffi2cpp_indy2i(p.maxNumSlotsOfMachine),
                 ffi2cpp_i2i(p.maxNumSlotsOfJob),
                 ffi2cpp_i2i(p.maxNumRunsPerSlotOfJob),
                 ffi2cpp_i2frac(p.materialBonus),
                 ffi2cpp_i2frac(p.timeBonus),
                 ffi2cpp_schedule(*p.approximation),
                 p.float2int);
  // clang-format on
}

void make_fraction(FfiFraction& frac, Fraction data) {
  // TODO now that dart uses int64_t not sure if i need this check here!!!!
  if (data.num > 2147483647 || data.den > 2147483647) {
    std::cout << "overflow in make_fraction" << std::endl;
    exit(1);
  }
  frac.numerator = data.num;
  frac.denominator = data.den;
}

void make_batchItem(batchItem& item, BatchItem data) {
  make_fraction(item.time, data.time);
  item.slots = data.slots;
  item.runs = data.runs;
}

void make_batch(batch& b, Batch data) {
  b.startTime = data.startTime;
  b.size = int(data.items.size());
  b.entries = (i2batchItemEntry*)calloc(data.items.size(), sizeof(i2batchItemEntry));
  int i = 0;
  for (auto& [k, v] : data.items) {
    auto& entry = b.entries[i];
    entry.key = k;
    make_batchItem(entry.value, v);
    i += 1;
  }
}

void make_batchList(batchList& element, vector<Batch> data) {
  element.size = int(data.size());
  element.entries = (batch*)calloc(data.size(), sizeof(batch));
  for (int i = 0; i < data.size(); ++i) {
    auto& entry = element.entries[i];
    make_batch(entry, data[i]);
  }
}

void make_k2batches(k2batches& element, map<IndustryType, vector<Batch>> data) {
  element.size = int(data.size());
  element.entries = (k2batchesEntry*)calloc(data.size(), sizeof(k2batchesEntry));
  int i = 0;
  for (auto& [k, v] : data) {
    auto& entry = element.entries[i];
    entry.key = k == IndustryType::MANUFACTURING ? MachineType::MANUFACTURING_ : MachineType::REACTION_;
    make_batchList(entry.value, v);
    i += 1;
  }
}

// we pass a schedule back to dart through the ffi and need to convert it
FfiSchedule* make_schedule(Schedule schedule) {
  auto result = (FfiSchedule*)calloc(1, sizeof(FfiSchedule));
  result->time = schedule.time;
  result->infeasible = schedule.infeasible;
  result->optimal = schedule.optimal;
  make_k2batches(result->machine2batches, schedule.machine2batches);
  return result;
}

void destroy_batch(batch& b) { free(b.entries); }

void destroy_batchList(batchList& element) {
  for (int i = 0; i < element.size; ++i) {
    auto& entry = element.entries[i];
    destroy_batch(entry);
  }
  free(element.entries);
}

void destroy_k2batches(k2batches& element) {
  for (int i = 0; i < element.size; ++i) {
    auto& entry = element.entries[i];
    destroy_batchList(entry.value);
  }
  free(element.entries);
}

// we make a schedule so we will have to delete the schedule when done with it
void destroy_schedule(FfiSchedule* schedule) {
  destroy_k2batches(schedule->machine2batches);
  free(schedule);
}
