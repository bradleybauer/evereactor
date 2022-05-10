#pragma once

#include <cmath>
#include <numeric>

#include "problem.h"

using std::max;
using std::min;

class Util {
  Util() {}

  static int64_t getNumNeeded(int node, map<int, int64_t>& inventory, map<int, int64_t>& numRuns, const bool getMax, Problem& p) {
    int64_t totalNumNeeded = 0;
    for (auto parent : p.inverseDependencies.at(node)) {
      const int64_t parentNumRuns = getNumRuns(parent, inventory, numRuns, getMax, p);
      const int64_t childPerParent = p.dependencies.at(parent).at(node);
      const Fraction pq = max(Fraction(1), p.materialBonus.at(parent) * childPerParent);

      int64_t numNeededByParent = 0;
      if (getMax) {
        int64_t maxSlots = 0;
        if (p.job2machine.at(parent) == p.job2machine.at(node)) {
          maxSlots = min(parentNumRuns, (p.maxNumBatches.at(p.job2machine.at(parent)) - 1) * p.maxNumSlotsOfJob.at(parent));
        } else {
          maxSlots = min(parentNumRuns, p.maxNumBatches.at(p.job2machine.at(parent)) * p.maxNumSlotsOfJob.at(parent));
        }
        numNeededByParent = ceilMul(parentNumRuns - max(0ll, maxSlots - 1), pq);
        numNeededByParent += max(0ll, maxSlots - 1) * pq.toIntCeil();
      } else {
        numNeededByParent = ceilMul(parentNumRuns, pq);
      }

      totalNumNeeded += numNeededByParent;
    }
    return totalNumNeeded;
  }

  static int64_t getNumRuns(int node, map<int, int64_t>& inventory, map<int, int64_t>& numRuns, const bool getMax, Problem& p) {
    if (numRuns.contains(node)) {
      return numRuns.at(node);
    }
    if (!p.inverseDependencies.contains(node)) {
      numRuns[node] = p.runsExcess.at(node);
      return numRuns[node];
    }
    int64_t numNeeded = getNumNeeded(node, inventory, numRuns, getMax, p);

    if (inventory.contains(node)) {
      int64_t numRemain = max(0ll, inventory.at(node) - numNeeded);
      numNeeded = max(0ll, numNeeded - inventory.at(node));
      inventory[node] = numRemain;
    }

    numRuns[node] = ceilDiv(numNeeded, p.madePerRun.at(node));

    if (p.runsExcess.contains(node)) {
      numRuns[node] += p.runsExcess[node];
    }

    return numRuns[node];
  }

  static map<int, int64_t> getNumRunsHelper(bool getMax, Problem& p) {
    map<int, int64_t> inventory(p.inventory);
    map<int, int64_t> result;
    for (int node : p.jobTypes) {
      getNumRuns(node, inventory, result, getMax, p);
    }
    return result;
  }

public:
  static map<int, int64_t> getMinRunsPerJob(Problem& p) { return getNumRunsHelper(false, p); }
  static map<int, int64_t> getMaxRunsPerJob(Problem& p) { return getNumRunsHelper(true, p); }

  static int64_t ceilDiv(int64_t x, int64_t y) { return (x + y - 1) / y; }
  static int64_t ceilMul(int64_t x, const Fraction& y) { return (x * y.num + y.den - 1) / y.den; }
  static int64_t roundMul(int64_t x, const Fraction& y) { return (x * y.num + y.den / 2) / y.den; }

  static int64_t gcds(vector<int64_t> xs) {
    if (xs.size() == 0) {
      return 1;
    }
    int64_t gcd = xs.front();
    for (int64_t x : xs) {
      gcd = std::gcd(x, gcd);
    }
    return gcd;
  }
};