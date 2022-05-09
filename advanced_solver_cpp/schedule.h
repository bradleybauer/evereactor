#pragma once

#include <cmath>
#include <numeric>
#include <unordered_map>
#include <vector>

#include "fraction.h"
#include "industry_type.h"

#undef max

template <typename K, typename V> using map = std::unordered_map<K, V>;
using std::vector;

struct BatchItem {
  int runs = 0;
  int slots = 0;
  Fraction time = Fraction(0);
  BatchItem(int runs, int slots, Fraction time) : runs(runs), slots(slots), time(time) {}
  BatchItem() {}
};

struct Batch {
    Batch(){}
    map<int, BatchItem> items{};

  Fraction getMaxTimeOfBatch() {
    Fraction result = Fraction(0);
    for (auto [tid, batch] : items) {
      result = std::max(result, batch.time);
    }
    return result;
  }
};

struct Schedule {
    Schedule() {}
    map<IndustryType, vector<Batch>> machine2batches{};
  double time = 0.0;
  bool optimal = false;
  bool infeasible = false;
};