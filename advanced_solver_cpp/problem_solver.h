#include <atomic>
#include <cmath>
#include <iostream>

#include "ortools/base/logging.h"
#include "ortools/sat/cp_model.h"
#include "ortools/sat/cp_model.pb.h"
#include "ortools/sat/cp_model_solver.h"
#include "ortools/sat/model.h"
#include "ortools/sat/sat_parameters.pb.h"
#include "ortools/util/time_limit.h"

#include "problem.h"
#include "util.h"
#include "variable_manager.h"

using std::endl;
using std::max;

using namespace operations_research;
using namespace sat;

class ProblemSolver {
public:
  ProblemSolver(Problem problem, std::function<void(std::optional<Schedule>)> callback) : p(problem), callback(callback) {}

  void solve() {
    std::cout << "in solve" << std::endl;
    // setup
    reduceJobTimeWithGCD();
    std::cout << "in solve after reduce time" << std::endl;
    getInverseDependencies();
    getNumBatchBounds();
    getNumRunsBounds();
    getScheduleTimeBounds();
    getFloat2Int();
    // std::cout << "\n--------- Problem Description ---------" << std::endl;
    // p.print();
    applyFloat2Int();
    std::cout << "in solve after setup" << std::endl;

    // solve
    runsSlotsVars();
    std::cout << "in solve after runsSlotsVars" << std::endl;
    timeOfJobTypeOnBatch();
    std::cout << "in solve after timeOfJobTypeOnBatch" << std::endl;
    batchTimes();
    std::cout << "in solve after batchTimes" << std::endl;
    batchOrderSymmetryConstraint();
    std::cout << "in solve after batchOrderSymmetryConstraint" << std::endl;
    balanceConstraint();
    std::cout << "in solve after balanceConstraint" << std::endl;
    completionTimes();
    std::cout << "in solve after completionTimes" << std::endl;
    startsWithVars();
    std::cout << "in solve after startsWithVars" << std::endl;
    numChildNeededVars();
    std::cout << "in solve after numChildNeededVars" << std::endl;
    enoughChildrenBuiltConstraint();
    std::cout << "in solve after enoughChildrenBuiltConstraint" << std::endl;
    minMaxNumRunsConstraints();
    std::cout << "in solve after minMaxNumRunsConstraints" << std::endl;
    numRunsConstraint();
    std::cout << "in solve after numRunsConstraint" << std::endl;
    numSlotsUsedConstraint();
    std::cout << "in solve after numSlotsUsedConstraint" << std::endl;
    numSlotsLessThanRunsConstraint();
    std::cout << "in solve after numSlotsLessThanRunsConstraint" << std::endl;

    Model model;
    SatParameters parameters;
    parameters.set_log_search_progress(true);
    parameters.set_log_subsolver_statistics(true);
    model.Add(NewSatParameters(parameters));
    model.Add(getSolutionObserver());

    // Create an atomic Boolean that will be periodically checked by the limit.
    model.GetOrCreate<TimeLimit>()->RegisterExternalBooleanAsLimit(&stopped);

    const CpSolverResponse response = SolveCpModel(m.Build(), &model);

    // notify UI type of solution we found

    LOG(INFO) << "Number of solutions found: " << num_solutions;
  }

private:
  CpModelBuilder m{};
  VariableManager vm{m};
  Problem p;

  std::function<void(std::optional<Schedule>)> callback;
  std::atomic<bool> stopped{false};
  std::atomic<int64_t> num_solutions = 0;

  void reduceJobTimeWithGCD() {
    vector<int> times;
    for (const auto& [k, v] : p.timePerRun) {
      times.push_back(v);
    }
    p.timesGCD = Util::gcds(times);
    for (auto& [k, v] : p.timePerRun) {
      p.timePerRun[k] = v / p.timesGCD;
    }
  }

  void getInverseDependencies() {
    for (auto [parent, children2qty] : p.dependencies) {
      for (auto [child, qty] : children2qty) {
        p.inverseDependencies[child].push_back(parent);
      }
    }
  }

  void getNumBatchBounds() {
    for (auto machine : p.machines) {
      p.minNumBatches[machine] = 0;
    }
    for (auto machine : p.machines) {
      p.maxNumBatches[machine] = 2 * p.approximation.machine2batches[machine].size();
    }
  }

  void getNumRunsBounds() {
    p.minNumRuns = Util::getMinRunsPerJob(p);
    p.maxNumRuns = Util::getMaxRunsPerJob(p);
  }

  void getScheduleTimeBounds() {
    p.completionTimeUpperBound = round(p.approximation.time);
    std::cout << "completionTimeUpperBound:" << p.completionTimeUpperBound << std::endl;

    int lb = 0;
    for (int k : p.jobTypes) {
      lb = max(lb, (p.minNumRuns[k] * p.timePerRun[k]) / min(max(1, p.minNumRuns[k]), p.maxNumSlotsOfJob[k]));
    }

    for (auto machine : p.machines) {
      int sum = 0;
      for (int k : p.jobTypes) {
        if (p.job2machine[k] == machine) {
          sum += p.minNumRuns[k] * p.timePerRun[k];
        }
      }
      sum /= p.maxNumSlotsOfMachine[machine];
      lb = max(lb, sum);
    }

    p.completionTimeLowerBound = lb;
    std::cout << "completionTimeLowerBound:" << p.completionTimeLowerBound << std::endl;
  }

  void getFloat2Int() {
    p.float2int = 1;
    for (int k : p.jobTypes) {
      p.float2int = max(p.float2int, p.materialBonus[k].den);
    }
  }

  void applyFloat2Int() {
    for (int k : p.jobTypes) {
      p.madePerRun[k] *= p.float2int;
    }
    for (auto& [k, child2qty] : p.dependencies) {
      for (auto& [child, qty] : child2qty) {
        child2qty[child] *= p.float2int;
      }
    }
    for (auto& [k, v] : p.inventory) {
      p.inventory[k] *= p.float2int;
    }
  }

  void runsSlotsVars() {
    for (int k : p.jobTypes) {
      auto machine = p.job2machine[k];
      for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
        vm.i("runs", {k, b}, 0, p.maxNumRuns[k]);
        vm.i("slots", {k, b}, 0, p.maxNumSlotsOfJob[k]);
      }
    }
  }

  void timeOfJobTypeOnBatch() {
    for (int k : p.jobTypes) {
      auto machine = p.job2machine[k];
      for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
        auto divisor = vm.i("runsPerSlotDivisors", {k, b}, 1, p.maxNumSlotsOfJob[k]);
        auto quotient = vm.i("runsPerSlotQuotients", {k, b}, 0, min(p.maxNumRuns[k], p.maxNumRunsPerSlotOfJob[k]));
        auto remainder = vm.i("runsPerSlotRemainders", {k, b}, 0, p.maxNumSlotsOfJob[k] - 1);
        auto notDivides = vm.b("runsPerSlotNotDivides", {k, b});
        m.AddMaxEquality(divisor, {vm.i("slots", {k, b}), 1});
        m.AddDivisionEquality(quotient, vm.i("runs", {k, b}), divisor);
        m.AddModuloEquality(remainder, vm.i("runs", {k, b}), divisor);
        m.AddNotEqual(remainder, 0).OnlyEnforceIf(notDivides);
        m.AddEquality(remainder, 0).OnlyEnforceIf(notDivides.Not());
        auto maxRunsPerSlot = quotient + notDivides;
        vm.e("timeOfJobTypeOnBatch", {k, b}, maxRunsPerSlot * p.timePerRun[k]);
      }
    }
  }

  void batchTimes() {
    for (auto machine : p.machines) {
      for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
        vector<LinearExpr> jobTimesOnBatch;
        for (int k : p.jobTypes) {
          if (p.job2machine[k] == machine) {
            jobTimesOnBatch.push_back(vm.e("timeOfJobTypeOnBatch", {k, b}));
          }
        }
        auto batchTime = vm.i(machine2str.at(machine) + "BatchTimes", {b}, 0, p.completionTimeUpperBound);
        m.AddMaxEquality(batchTime, jobTimesOnBatch);
      }
    }
  }

  void batchOrderSymmetryConstraint() {
    std::cout << "in bos" << std::endl;
    for (auto machine : p.machines) {
      std::cout << "in bos iter : "  << machine2str.at(machine) << std::endl;
      BoolVar prevIsUsed;
      bool prevIsUsedIsNone = true;
      for (int b = 0; b < p.minNumBatches[machine]; ++b) {
        LinearExpr rs = 0;
        for (int k : p.jobTypes) {
          if (p.job2machine[k] == machine) {
            rs += vm.i("runs", {k, b});
          }
        }
        m.AddGreaterThan(rs, 0);
        m.AddGreaterThan(vm.i(machine2str.at(machine) + "BatchTimes", {b}), 0);
      }
      std::cout << "in bos after b1 "  << machine2str.at(machine) << std::endl;
      if (p.minNumBatches[machine] > 0) {
        prevIsUsed = m.TrueVar();
        prevIsUsedIsNone = false;
      }
      std::cout << "in bos after b2 maxNumBatches[machine]=" << p.maxNumBatches[machine] << std::endl;
      for (int b = p.minNumBatches[machine]; b < p.maxNumBatches[machine]; ++b) {
        LinearExpr rs;
        std::cout << "in bos in b2" << std::endl;
        for (int k : p.jobTypes) {
          if (p.job2machine[k] == machine) {
            rs += vm.i("runs", {k, b});
          }
        }
        std::cout << "in bos in b2 after b1" << std::endl;
        BoolVar isUsed = vm.b(machine2str.at(machine) + "BatchIsUseds", {b});
        m.AddGreaterThan(rs, 0).OnlyEnforceIf(isUsed);
        m.AddEquality(rs, 0).OnlyEnforceIf(isUsed.Not());
        std::cout << "a" << std::endl;
        m.AddGreaterThan(vm.i(machine2str.at(machine) + "BatchTimes", {b}), 0).OnlyEnforceIf(isUsed);
        std::cout << "b" << std::endl;
        m.AddEquality(vm.i(machine2str.at(machine) + "BatchTimes", {b}), 0).OnlyEnforceIf(isUsed.Not());
        std::cout << "c" << std::endl;
        if (!prevIsUsedIsNone) {
          m.AddImplication(prevIsUsed.Not(), isUsed.Not());
        }
        prevIsUsed = isUsed;
        prevIsUsedIsNone = false;
      }
      std::cout << "in bos after b3 " << std::endl;
    }
  }

  void balanceConstraint() {
    for (int k : p.jobTypes) {
      auto machine = p.job2machine[k];
      for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
        auto equivalentNumRuns = vm.i("balanceConstraint_equivalentNumRuns", {k, b}, 0, p.completionTimeUpperBound);
        m.AddDivisionEquality(equivalentNumRuns, vm.i(machine2str.at(machine) + "BatchTimes", {b}), p.timePerRun[k]);
        auto denominator = vm.i("balanceConstraint_denominator", {k, b}, 1, p.completionTimeUpperBound);
        m.AddMaxEquality(denominator, {1, equivalentNumRuns});
        auto numerator = vm.i("balanceConstraint_numerator", {k, b}, 0, p.maxNumRuns[k] + p.completionTimeUpperBound - 1);
        m.AddEquality(numerator, vm.i("runs", {k, b}) + denominator - 1);
        m.AddDivisionEquality(vm.i("slots", {k, b}), numerator, denominator);
      }
    }
  }

  void completionTimes() {
    if (p.machines.contains(IndustryType::MANUFACTURING) && p.machines.contains(IndustryType::REACTION)) {
      const auto arr = std::array<IndustryType, 2>{IndustryType::REACTION, IndustryType::MANUFACTURING};
      for (auto machine : arr) {
        LinearExpr initial = 0;
        if (machine == IndustryType::MANUFACTURING and p.manufacturingDependsOnReaction) {
          initial = vm.i("InitialM2BatchStartTime", {0}, 0, p.completionTimeUpperBound);
          std::cout << "in completionTimes after before vm.e" << std::endl;
          m.AddLessOrEqual(initial, vm.e("M1EndTimes", {p.maxNumBatches[IndustryType::REACTION] - 1}));
          std::cout << "in completionTimes after after vm.e" << std::endl;
        }
        LinearExpr prevEnd;
        bool isPrevEndNone = true;
        for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
            LinearExpr start;
            if (!isPrevEndNone) {
                start = vm.e(machine2str.at(machine) + "StartTimes", {b}, prevEnd);
            } else {
                start = vm.e(machine2str.at(machine) + "StartTimes", { b }, initial);
            }
            prevEnd = vm.e(machine2str.at(machine) + "EndTimes", { b }, start + vm.i(machine2str.at(machine) + "BatchTimes", { b }));
            isPrevEndNone = false;
        }
      }
      std::cout << "in completionTimes after a" << std::endl;
      auto completionTimeManufacturing = vm.e("M2EndTimes", {p.maxNumBatches[IndustryType::MANUFACTURING] - 1});
      std::cout << "in completionTimes after b" << std::endl;
      auto completionTimeReaction = vm.e("M1EndTimes", {p.maxNumBatches[IndustryType::REACTION] - 1});
      std::cout << "in completionTimes after d" << std::endl;
      auto scheduleCompletionTime = vm.i("scheduleCompletionTime", {0}, p.completionTimeLowerBound, p.completionTimeUpperBound);
      std::cout << "in completionTimes after e" << std::endl;
      m.AddMaxEquality(scheduleCompletionTime, {completionTimeManufacturing, completionTimeReaction});
    } else {
      for (auto machine : p.machines) {
        LinearExpr startTime = 0;
        for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
          vm.e(machine2str.at(machine) + "StartTimes", {b}, startTime);
          startTime += vm.i(machine2str.at(machine) + "BatchTimes", {b});
        }
        auto scheduleCompletionTime = vm.e("scheduleCompletionTime", {0}, startTime);
        m.AddGreaterOrEqual(scheduleCompletionTime, p.completionTimeLowerBound);
        m.AddLessOrEqual(scheduleCompletionTime, p.completionTimeUpperBound);
      }
    }
  }

  void startsWithVars() {
    if (p.manufacturingDependsOnReaction && p.machines.contains(IndustryType::MANUFACTURING) && p.machines.contains(IndustryType::REACTION)) {
      for (int b = 0; b < p.maxNumBatches[IndustryType::REACTION]; ++b) {
        for (int bb = 0; bb < p.maxNumBatches[IndustryType::MANUFACTURING]; ++bb) {
          auto pastStart = vm.b("M2BatchAfterM1BatchStart", {bb, b});
          m.AddGreaterOrEqual(vm.e("M2StartTimes", {bb}), vm.b("M1StartTimes", {b})).OnlyEnforceIf(pastStart);
          m.AddLessThan(vm.e("M2StartTimes", {bb}), vm.b("M1StartTimes", {b})).OnlyEnforceIf(pastStart.Not());

          auto beforeEnd = vm.b("M2BatchBeforeM1BatchEnd", {bb, b});
          m.AddLessThan(vm.e("M2StartTimes", {bb}), vm.e("M1EndTimes", {b})).OnlyEnforceIf(beforeEnd);
          m.AddGreaterOrEqual(vm.e("M2StartTimes", {bb}), vm.e("M1EndTimes", {b})).OnlyEnforceIf(beforeEnd.Not());

          auto M2StartsDuringM1 = vm.b("M2StartsDuringM1", {bb, b});
          m.AddEquality(pastStart, beforeEnd).OnlyEnforceIf(M2StartsDuringM1);
          m.AddNotEqual(pastStart, beforeEnd).OnlyEnforceIf(M2StartsDuringM1.Not());
        }
      }
    }
  }

  void numChildNeededVars() {
    for (auto& [parent, child2qty] : p.dependencies) {
      for (auto& [child, childPerParent] : child2qty) {
        int bonusedChildPerParent = Util::roundMul(childPerParent, p.materialBonus[parent]);
        bonusedChildPerParent = max(int(p.float2int), bonusedChildPerParent);
        int maxNumNeededPerSlot = max(1, min(p.maxNumRuns[parent], p.maxNumRunsPerSlotOfJob[parent])) * childPerParent;
        int maxNumNeeded = max(1, p.maxNumRuns[parent]) * childPerParent;
        for (int b = 0; b < p.maxNumBatches[p.job2machine[parent]]; ++b) {
          const auto index = {parent, child, b};
          auto numChildNeededPerSlotFloor = vm.i("numChildNeededPerSlotFloor", index, 0, maxNumNeededPerSlot);
          auto numChildNeededPerSlotCeil = vm.i("numChildNeededPerSlotCeil", index, 0, maxNumNeededPerSlot + childPerParent);
          auto totalNumNeededFloor = vm.i("totalNumNeededFloor", index, 0, maxNumNeeded);
          auto totalNumNeededCeil = vm.i("totalNumNeededCeil", index, 0, maxNumNeeded);

          auto quotient = vm.i("runsPerSlotQuotients", {parent, b});
          m.AddGreaterOrEqual(numChildNeededPerSlotFloor, quotient * bonusedChildPerParent);
          m.AddLessThan(numChildNeededPerSlotFloor, quotient * bonusedChildPerParent + p.float2int);
          m.AddModuloEquality(0, numChildNeededPerSlotFloor, p.float2int);

          m.AddGreaterOrEqual(numChildNeededPerSlotCeil, (quotient + 1) * bonusedChildPerParent);
          m.AddLessThan(numChildNeededPerSlotCeil, (quotient + 1) * bonusedChildPerParent + p.float2int);
          m.AddModuloEquality(0, numChildNeededPerSlotCeil, p.float2int);

          auto diff = vm.i("numChildNeededVars_diff", {parent, b}, 0, p.maxNumSlotsOfJob[parent]);
          auto remainder = vm.i("runsPerSlotRemainders", {parent, b});
          m.AddEquality(diff, vm.i("slots", {parent, b}) - remainder);
          m.AddMultiplicationEquality(totalNumNeededFloor, {numChildNeededPerSlotFloor, diff});
          m.AddMultiplicationEquality(totalNumNeededCeil, {numChildNeededPerSlotCeil, remainder});
          auto totalNumChildNeeded = vm.e("totalNumChildNeeded", index, totalNumNeededFloor + totalNumNeededCeil);
          m.AddLessOrEqual(totalNumChildNeeded, maxNumNeeded);

          m.AddLessOrEqual(vm.i("runs", {parent, b}) * bonusedChildPerParent, totalNumChildNeeded);
        }
      }
    }
  }

  void enoughChildrenBuiltConstraint() {
    for (auto& [child, parents] : p.inverseDependencies) {
      LinearExpr built = 0;
      LinearExpr consumed = 0;
      const int inventory = p.inventory.contains(child) ? p.inventory[child] : 0;
      for (int b = 0; b < p.maxNumBatches[p.job2machine[child]]; ++b) {
        if (0 < b) {
          built += vm.i("runs", {child, b - 1}) * p.madePerRun[child];
        }
        for (int parent : parents) {
          const int maxNumNeeded = p.maxNumRuns[parent] * p.dependencies[parent][child];
          if (p.job2machine[parent] == p.job2machine[child]) {
            consumed += vm.e("totalNumChildNeeded", {parent, child, b});
          } else if (p.job2machine[parent] == IndustryType::MANUFACTURING) {
            for (int bb = 0; bb < p.maxNumBatches[IndustryType::MANUFACTURING]; ++bb) {
              auto consumedByM2 = vm.i("consumedByM2", {parent, child, bb, b}, 0, maxNumNeeded);
              auto M2StartsDuringM1 = vm.b("M2StartsDuringM1", {bb, b});
              m.AddEquality(consumedByM2, vm.e("totalNumChildNeeded", {parent, child, bb})).OnlyEnforceIf(M2StartsDuringM1);
              m.AddEquality(consumedByM2, 0).OnlyEnforceIf(M2StartsDuringM1.Not());
              consumed += consumedByM2;
            }
          }
        }
        m.AddGreaterOrEqual(built + inventory, consumed);
      }
      built += vm.i("runs", {child, p.maxNumBatches[p.job2machine[child]] - 1}) * p.madePerRun[child];

      if (p.job2machine[child] == IndustryType::REACTION) {
        bool hasM2Parents = false;
        for (int parent : parents) {
          if (p.job2machine[parent] == IndustryType::MANUFACTURING) {
            hasM2Parents = true;
            break;
          }
        }
        if (hasM2Parents) {
          LinearExpr grandTotalNumChildNeeded = 0;
          for (int parent : parents) {
            for (int b = 0; b < p.maxNumBatches[p.job2machine[parent]]; ++b) {
              grandTotalNumChildNeeded += vm.e("totalNumChildNeeded", {parent, child, b});
            }
          }
          m.AddGreaterOrEqual(built + inventory, grandTotalNumChildNeeded);
          consumed = grandTotalNumChildNeeded;
        }
      }

      auto amountNotProvidedByInventory = vm.i("amountNotProvidedByInventory", {child}, 0, p.maxNumRuns[child] * p.madePerRun[child]);
      m.AddMaxEquality(amountNotProvidedByInventory, {0, consumed - inventory});
      auto excess = vm.e("excess", {child}, built - amountNotProvidedByInventory);
      if (!p.runsExcess.contains(child)) {
        m.AddLessThan(excess, p.madePerRun[child]);
      }
    }
  }

  void minMaxNumRunsConstraints() {
    for (int k : p.jobTypes) {
      LinearExpr runSum = 0;
      for (int b = 0; b < p.maxNumBatches[p.job2machine[k]]; ++b) {
        runSum += vm.i("runs", {k, b});
      }
      m.AddLessOrEqual(runSum, p.maxNumRuns[k]);
      m.AddGreaterOrEqual(runSum, p.minNumRuns[k]);
    }
  }

  void numRunsConstraint() {
    for (auto& [k, runs] : p.runsExcess) {
      if (p.inverseDependencies.contains(k)) {
        auto excess = vm.e("excess", {k});
        const int required = runs * p.madePerRun[k];
        m.AddGreaterOrEqual(excess, required);
        m.AddLessThan(excess, required + p.madePerRun[k]);
      } else {
        LinearExpr sum = 0;
        for (int b = 0; b < p.maxNumBatches[p.job2machine[k]]; ++b) {
          sum += vm.i("runs", {k, b});
        }
        m.AddEquality(sum, runs);
      }
    }
  }

  void numSlotsUsedConstraint() {
    for (auto machine : p.machines) {
      for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
        LinearExpr sum = 0;
        for (int k : p.jobTypes) {
          if (p.job2machine[k] == machine) {
            sum += vm.i("slots", {k, b});
          }
        }
        m.AddLessOrEqual(sum, p.maxNumSlotsOfMachine[machine]);
      }
    }
  }

  void numSlotsLessThanRunsConstraint() {
    for (auto machine : p.machines) {
      for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
        for (int k : p.jobTypes) {
          if (p.job2machine[k] == machine) {
            m.AddLessOrEqual(vm.i("slots", {k, b}), vm.i("runs", {k, b}));
          }
        }
      }
    }
  }

  std::function<void(Model*)> getSolutionObserver() {
    return NewFeasibleSolutionObserver([&](const CpSolverResponse& r) {
      LOG(INFO) << "Solution " << num_solutions;
      double scale = p.timesGCD / 3600.;
      auto F = [&](auto x) { return round(100 * x * scale) / 100.; };
      auto Vi = [&](string a, vector<int> i) { return SolutionIntegerValue(r, vm.i(a, i)); };
      auto Vb = [&](string a, vector<int> i) { return SolutionIntegerValue(r, vm.b(a, i)); };
      auto Ve = [&](string a, vector<int> i) { return SolutionIntegerValue(r, vm.e(a, i)); };
      for (auto machine : {IndustryType::REACTION, IndustryType::MANUFACTURING}) {
        if (p.machines.contains(machine)) {
          if (machine == IndustryType::REACTION) {
            LOG(INFO) << "    Reactions";
          } else {
            LOG(INFO) << "    Manufacturing";
          }
          for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
            int64_t batchTime = Vi(machine2str.at(machine) + "BatchTimes", {b});
            int64_t startTime = Ve(machine2str.at(machine) + "StartTimes", {b});
            if (batchTime == 0) {
              LOG(INFO) << "\tBatch:" << b << "is empty" << endl;
            } else {
              LOG(INFO) << "\tBatch:" << b << "\tStart:" << F(startTime) << "\tEnd:" << F(startTime + batchTime)
                        << "\tDuration:" << F(batchTime) << endl;
            }
            for (int k : p.jobTypes) {
              if (p.job2machine[k] == machine) {
                int64_t s = Vi("slots", {k, b});
                if (s == 0) {
                  continue;
                }
                int64_t r = Vi("runs", {k, b});
                int64_t t = Vi("timeOfJobTypeOnBatch", {k, b});
                LOG(INFO) << "\t" << k << "\tr:" << r << "   \ts:" << s << "\tt:" << F(t) << endl;
              }
            }
          }
          LOG(INFO) << endl;
        }
      }
      int64_t maxT = Vi("scheduleCompletionTime", {0});
      int64_t ub = p.completionTimeUpperBound;
      int64_t lb = p.completionTimeLowerBound;
      LOG(INFO) << "\t  - upperbound : " << ub * scale << endl;
      LOG(INFO) << "\t  - sched time : " << maxT * scale << endl;
      LOG(INFO) << "\t  - lowerbound : " << lb * scale << endl;
      if (lb > 0) {
        LOG(INFO) << "\t  - time/lb    : " << maxT / lb << endl;
      }
      if (ub > 0) {
        LOG(INFO) << "\t  - 1-time/ub  : " << (1 - maxT / ub) << endl;
      }
      LOG(INFO) << "\t  - real time  : " << r.wall_time() << endl;
      LOG(INFO) << endl;
      num_solutions++;

      //Schedule schedule;
      //callback(schedule);
    });
  }

  //   void getHints(map<LinearExpr,int>)
};