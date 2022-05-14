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
  map<int, int64_t> runsExcess;
  map<int, int64_t> madePerRun;
  map<int, int64_t> timePerRun;
  map<int, IndustryType> job2machine;
  map<int, map<int, int64_t>> dependencies;
  map<int, int64_t> inventory;
  map<IndustryType, int64_t> maxNumSlotsOfMachine;
  map<int, int64_t> maxNumSlotsOfJob;
  map<int, int64_t> maxNumRunsPerSlotOfJob;
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
  map<int, int64_t> maxNumRuns;
  map<int, int64_t> minNumRuns;
  int64_t completionTimeUpperBound = -1;
  int64_t completionTimeLowerBound = -1;
  map<int, vector<int>> inverseDependencies;
  int64_t timesGCD = -1;

  void print_i2i(string name, map<int, int64_t> m) {
    std::cout << name << ".size()=" << m.size() << std::endl;
    for (auto& [k, v] : m) {
      std::cout << k << " " << v << std::endl;
    }
  }

  void print() {
    print_i2i("runsExcess", runsExcess);
    print_i2i("madePerRun", madePerRun);
    print_i2i("timePerRun", timePerRun);
    std::cout << "job2machine.size()=" << job2machine.size() << std::endl;
    for (auto& [k, v] : job2machine) {
      std::cout << k << " " << (v == IndustryType::MANUFACTURING ? "mfg" : "rtn") << std::endl;
    }
    std::cout << "dependencies.size()=" << dependencies.size() << std::endl;
    for (auto& [k, v] : dependencies) {
      std::cout << k << std::endl;
      for (auto& [kk, vv] : v) {
        std::cout << "\t" << kk << " " << vv << std::endl;
      }
    }
    print_i2i("inventory", inventory);
    std::cout << "maxNumSlotsOfMachine.size()=" << maxNumSlotsOfMachine.size() << std::endl;
    for (auto& [k, v] : maxNumSlotsOfMachine) {
      std::cout << (k == IndustryType::MANUFACTURING ? "mfg" : "rtn") << " " << v << std::endl;
    }
    print_i2i("maxNumSlotsOfJob", maxNumSlotsOfJob);
    print_i2i("maxNumRunsPerSlotOfJob", maxNumRunsPerSlotOfJob);
    std::cout << "materialBonus.size()" << materialBonus.size() << std::endl;
    for (auto& [k, v] : materialBonus) {
      std::cout << k << " " << v.num << "/" << v.den << std::endl;
    }
    std::cout << "timeBonus.size()" << timeBonus.size() << std::endl;
    for (auto& [k, v] : timeBonus) {
      std::cout << k << " " << v.num << "/" << v.den << std::endl;
    }
    std::cout << "float2int:" << float2int << std::endl;
    std::cout << "timesGCD:" << timesGCD << std::endl;
    std::cout << "mfg depends on rtn:" << manufacturingDependsOnReaction << std::endl;
    approximation.print();
  }

  // clang-format off
  Problem(map<int, int64_t> runsExcess,
          map<int, int64_t> madePerRun,
          map<int, int64_t> timePerRun,
          map<int, IndustryType> job2machine,
          map<int, map<int, int64_t>> dependencies,
          map<int, int64_t> inventory,
          map<IndustryType, int64_t> maxNumSlotsOfMachine,
          map<int, int64_t> maxNumSlotsOfJob,
          map<int, int64_t> maxNumRunsPerSlotOfJob,
          map<int, Fraction> materialBonus,
          map<int, Fraction> timeBonus,
          Schedule approximation,
          int64_t float2int = 1000)
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
        approximation(approximation),
        float2int(float2int) {

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