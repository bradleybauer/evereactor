#pragma once

#include <iostream>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "fraction.h"
#include "industry_type.h"
#include "schedule.h"

template <typename K, typename V> using map = std::unordered_map<K, V>;

using std::string;
using std::unordered_set;
using std::vector;

struct Problem {
  map<int, int> runsExcess;
  unordered_set<int> tids;
  map<int, int> madePerRun;
  map<int, int> timePerRun;
  map<int, IndustryType> job2machine;
  map<int, map<int, int>> dependencies;
  map<int, int> inventory;
  map<IndustryType, int> maxNumSlotsOfMachine;
  map<int, int> maxNumSlotsOfJob;
  map<int, int> maxNumRunsPerSlotOfJob;
  map<int, Fraction> materialBonus;
  map<int, Fraction> timeBonus;
  int64_t float2int;
  Schedule approximation;

  // computed in constructor from args
  vector<int> jobTypes;
  unordered_set<IndustryType> machines;
  bool manufacturingDependsOnReaction = false;

  // to be computed later
  map<IndustryType, int> minNumBatches;
  map<IndustryType, int> maxNumBatches;
  map<int, int> maxNumRuns;
  map<int, int> minNumRuns;
  int completionTimeUpperBound = -1;
  int completionTimeLowerBound = -1;
  map<int, vector<int>> inverseDependencies;
  int timesGCD = -1;

  void printi2i(string name, map<int, int> m) {
    std::cout << name <<".size()=" << m.size() << std::endl;
    for (auto& [k, v] : m) {
        std::cout << k << " " << v << std::endl;
    }
  }

  void print() {
    printi2i("runsExcess", runsExcess);
    std::cout << "tids.size()=" << tids.size() << std::endl;
    for (auto& k : tids) {
        std::cout << k << std::endl;
    }
    printi2i("madePerRun", madePerRun);
    printi2i("timePerRun", timePerRun);
    std::cout << "job2machine.size()=" << job2machine.size() << std::endl;
    for (auto& [k, v] : job2machine) {
        std::cout << k << " " << (v==IndustryType::MANUFACTURING?"mfg":"rtn") << std::endl;
    }
    std::cout << "dependencies.size()=" << dependencies.size() << std::endl;
    for (auto& [k, v] : dependencies) {
        std::cout << k << std::endl;
        for (auto& [kk, vv] : v) {
            std::cout << "\t" << kk << " " << vv << std::endl;
        }
    }
    printi2i("inventory", inventory);
    std::cout << "maxNumSlotsOfMachine.size()=" << maxNumSlotsOfMachine.size() << std::endl;
    for (auto& [k, v] : maxNumSlotsOfMachine) {
        std::cout << (k ==IndustryType::MANUFACTURING?"mfg":"rtn") << " " << v << std::endl;
    }
    printi2i("maxNumSlotsOfJob", maxNumSlotsOfJob);
    printi2i("maxNumRunsPerSlotOfJob", maxNumRunsPerSlotOfJob);
    for (auto& [k, v] : materialBonus) {
        std::cout << k << " " << v.num << "/" << v.den << std::endl;
    }
    for (auto& [k, v] : timeBonus) {
        std::cout << k << " " << v.num << "/" << v.den << std::endl;
    }
    std::cout << float2int << std::endl;
    //schedule.print();
  }

  // clang-format off
  Problem(map<int, int> runsExcess,
          map<int, int> madePerRun,
          map<int, int> timePerRun,
          map<int, IndustryType> job2machine,
          map<int, map<int, int>> dependencies,
          map<int, int> inventory,
          map<IndustryType, int> maxNumSlotsOfMachine,
          map<int, int> maxNumSlotsOfJob,
          map<int, int> maxNumRunsPerSlotOfJob,
          map<int, Fraction> materialBonus,
          map<int, Fraction> timeBonus,
          Schedule approximation,
          int float2int = 1000)
      // clang-format on
      : runsExcess(runsExcess),
        madePerRun(madePerRun),
        timePerRun(timePerRun),
        job2machine(job2machine),
        dependencies(dependencies),
        inventory(inventory),
        maxNumSlotsOfMachine(maxNumSlotsOfMachine),
        maxNumSlotsOfJob(maxNumSlotsOfJob),
        maxNumRunsPerSlotOfJob(maxNumRunsPerSlotOfJob),
        materialBonus(materialBonus),
        timeBonus(timeBonus),
        approximation(approximation) {

    for (auto [k, v] : madePerRun) {
      jobTypes.push_back(k);
    }

    for (auto [k, v] : job2machine) {
      machines.insert(v);
    }

    // if there is a job that depends on a job ran on a different machine then there is some manufacturing job that
    // depends on a reaction job (cross machine dependencies only go in that direction)
    for (auto [u, m] : dependencies) {
      for (auto [v, unused] : m) {
        if (job2machine[u] != job2machine[v]) {
          manufacturingDependsOnReaction = true;
          break;
        }
      }
    }
  }
};