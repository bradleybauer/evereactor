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

    Fraction getMaxTimeOfBatch() const {
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

  std::string getSpacing(auto prev, int cells) {
      auto str = std::to_string(prev);
    return std::string(std::max(0,int(cells - str.size())), ' ');
  }


  void print() {
    for (auto machine : {IndustryType::REACTION, IndustryType::MANUFACTURING}) {
      if (machine2batches.contains(machine)) {
        if (machine == IndustryType::REACTION) {
          std::cout << "  Reactions";
        } else {
          std::cout << "  Manufacturing";
        }
        const auto& batches = machine2batches[machine];
        for (int b = 0;  const Batch & batch : batches) {
          double batchTime = batch.getMaxTimeOfBatch().toDouble();
          if (batchTime == 0) {
            std::cout << "\tBatch:" << b << "is empty" << std::endl;
          } else {
              std::cout << "\tBatch:" << b << getSpacing(b,3) << "Duration:" << batchTime << std::endl;
          }
          for (const auto&[tid, batchItem] : batch.items) {
            int64_t s = batchItem.slots;
            if (s == 0) {
              continue;
            }
            int64_t r = batchItem.runs;
            int64_t t = batchItem.time.toDouble();
            std::cout << "\t" << tid << getSpacing(tid, 10) << "  r:" << r << getSpacing(r, 10) << "   s:" << s << getSpacing(s, 10) << "t:" << t << getSpacing(t, 16) << std::endl;
          }
        ++b;
        }
        std::cout << std::endl;
      }
    }
  }

};