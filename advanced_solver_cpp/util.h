#pragma once

#include <cmath>
#include <numeric>

#include "problem.h"

using std::max;
using std::min;

class Util {
  Util() {}

  static int getNumNeeded(int node, map<int, int>& inventory, map<int, int>& numRuns, const bool getMax, Problem& p) {
    int totalNumNeeded = 0;
    for (auto parent : p.inverseDependencies.at(node)) {
      const int parentNumRuns = getNumRuns(parent, inventory, numRuns, getMax, p);
      const int childPerParent = p.dependencies.at(parent).at(node);
      const Fraction pq = max(Fraction(1), p.materialBonus.at(parent) * childPerParent);

      int numNeededByParent = 0;
      if (getMax) {
        int maxSlots = 0;
        if (p.job2machine.at(parent) == p.job2machine.at(node)) {
          maxSlots = min(parentNumRuns, (p.maxNumBatches.at(p.job2machine.at(parent)) - 1) * p.maxNumSlotsOfJob.at(parent));
        } else {
          maxSlots = min(parentNumRuns, p.maxNumBatches.at(p.job2machine.at(parent)) * p.maxNumSlotsOfJob.at(parent));
        }
        numNeededByParent = ceilMul(parentNumRuns - max(0, maxSlots - 1), pq);
        numNeededByParent += max(0, maxSlots - 1) * pq.toIntCeil();
      } else {
        numNeededByParent = ceilMul(parentNumRuns, pq);
      }

      totalNumNeeded += numNeededByParent;
    }
    return totalNumNeeded;
  }

  static int getNumRuns(int node, map<int, int>& inventory, map<int, int>& numRuns, const bool getMax, Problem& p) {
    if (numRuns.contains(node)) {
      return numRuns.at(node);
    }
    if (!p.inverseDependencies.contains(node)) {
      numRuns[node] = p.runsExcess.at(node);
      return numRuns[node];
    }
    int numNeeded = getNumNeeded(node, inventory, numRuns, getMax, p);

    if (inventory.contains(node)) {
      int numRemain = max(0, inventory.at(node) - numNeeded);
      numNeeded = max(0, numNeeded - inventory.at(node));
      inventory[node] = numRemain;
    }

    numRuns[node] = ceilDiv(numNeeded, p.madePerRun.at(node));

    if (p.runsExcess.contains(node)) {
      numRuns[node] += p.runsExcess[node];
    }

    return numRuns[node];
  }

  static map<int, int> getNumRunsHelper(bool getMax, Problem& p) {
    map<int, int> inventory(p.inventory);
    map<int, int> result;
    for (int node : p.jobTypes) {
      getNumRuns(node, inventory, result, getMax, p);
    }
    return result;
  }

public:
  static map<int, int> getMinRunsPerJob(Problem& p) { return getNumRunsHelper(false, p); }
  static map<int, int> getMaxRunsPerJob(Problem& p) { return getNumRunsHelper(true, p); }

  static int ceilDiv(int x, int y) { return (x + y - 1) / y; }
  static int ceilMul(int x, const Fraction& y) { return (x * y.num + y.den - 1) / y.den; }
  static int roundMul(int x, const Fraction& y) { return (x * y.num + y.den / 2) / y.den; }

  static int gcds(vector<int> xs) {
    int gcd = 1;
    for (int x : xs) {
      gcd = std::gcd(x, gcd);
    }
    return gcd;
  }
};