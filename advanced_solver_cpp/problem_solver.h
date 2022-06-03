// TODO check all todos pls
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
    // setup
    getInverseDependencies();
    getNumBatchBounds();
    getNumRunsBounds();
    getFloat2Int();
    applyFloat2Int();
    reduceJobTimeWithGCD();
    getScheduleTimeBounds();

    // solve
    runsSlotsVars();
    timeOfJobTypeOnBatch();
    batchTimes();
    batchOrderSymmetryConstraint();
    // balanceConstraint();
    maxRunPerSlotConstraint();
    completionTimes();
    startsWithVars();
    numChildNeededVars();
    enoughChildrenBuiltConstraint();
    minMaxNumRunsConstraints();
    numRunsConstraint();
    numSlotsUsedConstraint();
    numSlotsLessThanRunsConstraint();

    // getHints();

    LinearExpr obj = vm.i("scheduleCompletionTime", {0});
    for (auto machine : p.machines) {
      for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
        auto slots = vector<IntVar>{};
        for (int k : p.jobTypes) {
          if (p.job2machine[k] == machine) {
            slots.push_back(vm.i("slots", {k, b}));
          }
        }
        auto maxSlots = vm.i("maxSlotsUsed", {b}, 0, p.maxNumSlotsOfMachine[machine]);
        m.AddMaxEquality(maxSlots, slots);
        obj += maxSlots;
      }
    }

//    for (int k : p.jobTypes) {
//      auto machine = p.job2machine[k];
//      for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
//        obj += vm.i("slots", {k, b});
//      }
//    }
    m.Minimize(obj);

    Model model;
    SatParameters parameters;
    // parameters.set_log_search_progress(true);
    // parameters.set_log_subsolver_statistics(true);
    model.Add(NewSatParameters(parameters));
    model.Add(getSolutionObserver());
    // TODO choose runs then slots

    // Create an atomic Boolean that will be periodically checked by the limit.
    model.GetOrCreate<TimeLimit>()->RegisterExternalBooleanAsLimit(&stopped);

    auto result = SolveCpModel(m.Build(), &model);
    if (most_recent_schedule.has_value()) {
      if (result.status() == CpSolverStatus::OPTIMAL) {
        most_recent_schedule.value().optimal = true;
      }
      if (result.status() == CpSolverStatus::INFEASIBLE) {
        most_recent_schedule.value().infeasible = true;
      }
    }
    callback(most_recent_schedule);
  }

  void stop() { stopped = true; }

private:
  CpModelBuilder m{};
  VariableManager vm{m};
  Problem p;
  std::optional<Schedule> most_recent_schedule;

  std::function<void(std::optional<Schedule>)> callback;
  std::atomic<bool> stopped{false};
  std::atomic<int64_t> num_solutions = 0;

  void reduceJobTimeWithGCD() {
    vector<int64_t> times;
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
      p.minNumBatches[machine] = p.approximation.machine2batches[machine].size();
      p.maxNumBatches[machine] = p.minNumBatches[machine] + 3;
    }
  }

  void getNumRunsBounds() {
    // TODO now that I do not use material efficiency in this solver i can remove the get min/max runs code and just use get runs.
    p.minNumRuns = Util::getMinRunsPerJob(p);
    p.maxNumRuns = Util::getMaxRunsPerJob(p);
  }

  void getScheduleTimeBounds() {
    // TODO... forgot  what this todo is for
    p.completionTimeUpperBound = 8 * ceil(p.approximation.time / p.timesGCD * p.float2int);
    int64_t lb = 0;
    for (int k : p.jobTypes) {
      lb = max(lb, ((p.minNumRuns[k] * p.timePerRun[k]) /
                    min(max(1ll, p.maxNumRuns[k]), min(p.maxNumSlotsOfJob[k], p.maxNumSlotsOfMachine[p.job2machine[k]]))));
    }

    for (auto machine : p.machines) {
      int64_t sum = 0;
      for (int k : p.jobTypes) {
        if (p.job2machine[k] == machine) {
          sum += p.minNumRuns[k] * p.timePerRun[k];
        }
      }
      sum /= p.maxNumSlotsOfMachine[machine];
      lb = max(lb, sum);
    }

    p.completionTimeLowerBound = lb;
    if (p.completionTimeUpperBound < p.completionTimeLowerBound) {
      std::cout << "Inverted upper/lower completion time bounds" << std::endl;
      exit(1);
    }
  }

  void getFloat2Int() { p.float2int = 1000; }

  void applyFloat2Int() {
    for (int k : p.jobTypes) {
      p.timePerRun[k] = (p.timeBonus[k] * (p.timePerRun[k] * (p.float2int))).toIntCeil();
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
        auto denominator = vm.i("den", {k, b}, 1, p.maxNumSlotsOfJob[k]);
        m.AddMaxEquality(denominator, {1, vm.i("slots", {k, b})});
        auto numerator = vm.i("num", {k, b}, 0, p.maxNumRuns[k] + p.maxNumSlotsOfJob[k] - 1);
        m.AddEquality(numerator, vm.i("runs", {k, b}) + denominator - 1);
        auto runsPerSlotCeil = vm.i("div", {k, b}, 0, p.maxNumRuns[k]);
        m.AddDivisionEquality(runsPerSlotCeil, numerator, denominator);
        vm.e("timeOfJobTypeOnBatch", {k, b}, runsPerSlotCeil * p.timePerRun[k]);
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
    for (auto machine : p.machines) {
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
      if (p.minNumBatches[machine] > 0) {
        prevIsUsed = m.TrueVar();
        prevIsUsedIsNone = false;
      }
      for (int b = p.minNumBatches[machine]; b < p.maxNumBatches[machine]; ++b) {
        LinearExpr rs;
        for (int k : p.jobTypes) {
          if (p.job2machine[k] == machine) {
            rs += vm.i("runs", {k, b});
          }
        }
        BoolVar isUsed = vm.b(machine2str.at(machine) + "BatchIsUseds", {b});
        m.AddGreaterThan(rs, 0).OnlyEnforceIf(isUsed);
        m.AddEquality(rs, 0).OnlyEnforceIf(isUsed.Not());
        m.AddGreaterThan(vm.i(machine2str.at(machine) + "BatchTimes", {b}), 0).OnlyEnforceIf(isUsed);
        m.AddEquality(vm.i(machine2str.at(machine) + "BatchTimes", {b}), 0).OnlyEnforceIf(isUsed.Not());
        if (!prevIsUsedIsNone) {
          m.AddImplication(prevIsUsed.Not(), isUsed.Not());
        }
        prevIsUsed = isUsed;
        prevIsUsedIsNone = false;
      }
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

  void maxRunPerSlotConstraint() {
    for (int k : p.jobTypes) {
      auto machine = p.job2machine[k];
      for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
        auto denominator = vm.i("mrpl_denom", {k, b}, 1, p.maxNumSlotsOfJob[k]);
        m.AddMaxEquality(denominator, {1, vm.i("slots", {k, b})});
        auto numerator = vm.i("mrpl_num", {k, b}, 0, p.maxNumRuns[k] + p.maxNumSlotsOfJob[k] - 1);
        m.AddEquality(numerator, vm.i("runs", {k, b}) + denominator - 1);
        auto div = vm.i("mrpl_div", {k, b}, 0, p.maxNumRuns[k]);
        m.AddDivisionEquality(div, numerator, denominator);
        m.AddLessOrEqual(div, p.maxNumRunsPerSlotOfJob[k]);
      }
    }
  }

  void completionTimes() {
    if (p.machines.contains(IndustryType::MANUFACTURING) && p.machines.contains(IndustryType::REACTION)) {
      const auto arr = std::array<IndustryType, 2>{IndustryType::REACTION, IndustryType::MANUFACTURING};
      for (auto machine : arr) {
        LinearExpr initial = 0;
        if (machine == IndustryType::MANUFACTURING && p.manufacturingDependsOnReaction) {
          initial = vm.i("InitialM2BatchStartTime", {0}, 0, p.completionTimeUpperBound);
          m.AddLessOrEqual(initial, vm.e("M1EndTimes", {p.maxNumBatches[IndustryType::REACTION] - 1}));
        }
        LinearExpr prevEnd;
        bool isPrevEndNone = true;
        for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
          LinearExpr start;
          if (isPrevEndNone) {
            start = vm.e(machine2str.at(machine) + "StartTimes", {b}, initial);
          } else {
            start = vm.e(machine2str.at(machine) + "StartTimes", {b}, prevEnd);
          }
          prevEnd = vm.e(machine2str.at(machine) + "EndTimes", {b}, start + vm.i(machine2str.at(machine) + "BatchTimes", {b}));
          isPrevEndNone = false;
        }
      }
      auto completionTimeManufacturing = vm.e("M2EndTimes", {p.maxNumBatches[IndustryType::MANUFACTURING] - 1});
      auto completionTimeReaction = vm.e("M1EndTimes", {p.maxNumBatches[IndustryType::REACTION] - 1});
      auto scheduleCompletionTime = vm.i("scheduleCompletionTime", {0}, p.completionTimeLowerBound, p.completionTimeUpperBound);
      m.AddMaxEquality(scheduleCompletionTime, {completionTimeManufacturing, completionTimeReaction});
    } else {
      for (auto machine : p.machines) {
        LinearExpr startTime = 0;
        for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
          vm.e(machine2str.at(machine) + "StartTimes", {b}, startTime);
          startTime += vm.i(machine2str.at(machine) + "BatchTimes", {b});
        }
        auto scheduleCompletionTime = vm.i("scheduleCompletionTime", {0}, p.completionTimeLowerBound, p.completionTimeUpperBound);
        m.AddEquality(scheduleCompletionTime, startTime);
      }
    }
  }

  void startsWithVars() {
    if (p.manufacturingDependsOnReaction && p.machines.contains(IndustryType::MANUFACTURING) && p.machines.contains(IndustryType::REACTION)) {
      for (int b = 0; b < p.maxNumBatches[IndustryType::REACTION]; ++b) {
        for (int bb = 0; bb < p.maxNumBatches[IndustryType::MANUFACTURING]; ++bb) {
          auto pastStart = vm.b("M2BatchAfterM1BatchStart", {bb, b});
          m.AddGreaterOrEqual(vm.e("M2StartTimes", {bb}), vm.e("M1StartTimes", {b})).OnlyEnforceIf(pastStart);
          m.AddLessThan(vm.e("M2StartTimes", {bb}), vm.e("M1StartTimes", {b})).OnlyEnforceIf(pastStart.Not());

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
        for (int b = 0; b < p.maxNumBatches[p.job2machine[parent]]; ++b) {
          vm.e("totalNumChildNeeded", {parent, child, b}, vm.i("runs", {parent, b}) * childPerParent);
        }
      }
    }
  }
  void enoughChildrenBuiltConstraint() {
    for (auto& [child, parents] : p.inverseDependencies) {

      bool hasParentsOnSameMachine = false;
      bool hasParentsOnOppositeMachine = false;
      for (auto parent : parents) {
        if (p.job2machine[parent] != p.job2machine[child]) {
          hasParentsOnOppositeMachine = true;
        } else {
          hasParentsOnSameMachine = true;
        }
      }
      int64_t maxNumNeededByM2Parents = 0; // this is probably just a huge number
      if (hasParentsOnOppositeMachine) {   // only parent=manufacturing and child=reaction can lead here
        for (int b = 0; b < p.maxNumBatches[IndustryType::MANUFACTURING]; ++b) {
          LinearExpr consumedByM2 = 0;
          for (int parent : parents) {
            if (p.job2machine[parent] == IndustryType::MANUFACTURING) {
              maxNumNeededByM2Parents += p.maxNumRuns[parent] * p.dependencies[parent][child];
              consumedByM2 += vm.e("totalNumChildNeeded", {parent, child, b});
            }
          }
          vm.e("consumedByM2", {child, b}, consumedByM2);
        }
      }
      if (hasParentsOnSameMachine) {
        for (int b = 0; b < p.maxNumBatches[p.job2machine[child]]; ++b) {
          LinearExpr consumedBySame = 0;
          for (int parent : parents) {
            if (p.job2machine[parent] == p.job2machine[child]) {
              consumedBySame += vm.e("totalNumChildNeeded", {parent, child, b});
            }
          }
          vm.e("consumedBySame", {child, b}, consumedBySame);
        }
      }

      LinearExpr built = 0;
      LinearExpr consumed = 0;
      const int64_t inventory = p.inventory.contains(child) ? p.inventory[child] : 0;
      for (int b = 0; b < p.maxNumBatches[p.job2machine[child]]; ++b) {
        if (0 < b) {
          built += vm.i("runs", {child, b - 1}) * p.madePerRun[child];
        }
        if (hasParentsOnSameMachine) {
          consumed += vm.e("consumedBySame", {child, b});
        }
        if (hasParentsOnOppositeMachine) {
          for (int bb = 0; bb < p.maxNumBatches[IndustryType::MANUFACTURING]; ++bb) {
            auto consumedByM2 = vm.i("consumedByM2Optional", {child, bb, b}, 0, maxNumNeededByM2Parents);
            auto M2StartsDuringM1 = vm.b("M2StartsDuringM1", {bb, b});
            m.AddEquality(consumedByM2, vm.e("consumedByM2", {child, bb})).OnlyEnforceIf(M2StartsDuringM1);
            m.AddEquality(consumedByM2, 0).OnlyEnforceIf(M2StartsDuringM1.Not());
            consumed += consumedByM2;
          }
        }
        m.AddGreaterOrEqual(built + inventory, consumed);
      }
      built += vm.i("runs", {child, p.maxNumBatches[p.job2machine[child]] - 1}) * p.madePerRun[child];

      if (hasParentsOnOppositeMachine) {
        LinearExpr grandTotalNumChildNeeded = 0;
        for (int parent : parents) {
          for (int b = 0; b < p.maxNumBatches[p.job2machine[parent]]; ++b) {
            grandTotalNumChildNeeded += vm.e("totalNumChildNeeded", {parent, child, b});
          }
        }
        m.AddGreaterOrEqual(built + inventory, grandTotalNumChildNeeded);
        consumed = grandTotalNumChildNeeded;
      }

      // auto amountNotProvidedByInventory = vm.i("amountNotProvidedByInventory", {child}, 0, p.maxNumRuns[child] * p.madePerRun[child]);
      // m.AddMaxEquality(amountNotProvidedByInventory, {0, consumed - inventory});
      // auto excess = vm.e("excess", {child}, built - amountNotProvidedByInventory);
      vm.e("excess", {child}, built - consumed);
    }
  }

  void minMaxNumRunsConstraints() {
    for (int k : p.jobTypes) {
      LinearExpr runSum = 0;
      for (int b = 0; b < p.maxNumBatches[p.job2machine[k]]; ++b) {
        runSum += vm.i("runs", {k, b});
      }
      m.AddEquality(runSum, p.maxNumRuns[k]);
    }
  }

  void numRunsConstraint() {
    for (auto& [k, runs] : p.runsExcess) {
      if (p.inverseDependencies.contains(k)) {
        auto excess = vm.e("excess", {k});
        const int64_t required = runs * p.madePerRun[k];
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

            // if not using balance constraint then need to make sure runs>0=>slots>0
            auto B = vm.b("b", {k, b});
            m.AddGreaterThan(vm.i("runs", {k, b}), 0).OnlyEnforceIf(B);
            m.AddEquality(vm.i("runs", {k, b}), 0).OnlyEnforceIf(B.Not());
            m.AddGreaterThan(vm.i("slots", {k, b}), 0).OnlyEnforceIf(B);
          }
        }
      }
    }
  }

  // setting runs here will not help (maybe hurt even) since the approximator uses ME
  void getHints() {
    for (auto machine : p.machines) {
      for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
        if (b >= p.minNumBatches[machine]) {
          vm.bhint(machine2str.at(machine) + "BatchIsUseds", {b}, 0);
        }
        for (int k : p.jobTypes) {
          if (p.job2machine[k] == machine) {
            // vm.ihint("runs", {k, b}, 0);
            vm.ihint("slots", {k, b}, 0);
          }
        }
      }
      for (int b = 0; auto batch : p.approximation.machine2batches[machine]) {
        if (b >= p.minNumBatches[machine]) {
          vm.bhint(machine2str.at(machine) + "BatchIsUseds", {b}, 1);
        }
        for (auto& [k, item] : batch.items) {
          // vm.ihint("runs", {k, b}, item.runs);
          vm.ihint("slots", {k, b}, item.slots);
        }
      }

      for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
        auto i = {b};
        if (b >= p.minNumBatches[machine]) {
          string v = machine2str.at(machine) + "BatchIsUseds";
          m.AddHint(vm.b(v, i), vm.getHint(v, i));
        }
        for (int k : p.jobTypes) {
          if (p.job2machine[k] == machine) {
            auto ii = {k, b};
            // m.AddHint(vm.i("runs", ii), vm.getHint("runs", ii));
            m.AddHint(vm.i("slots", ii), vm.getHint("slots", ii));
          }
        }
      }
    }
  }

  std::string getSpacing(auto prev, int cells) {
    auto str = std::to_string(prev);
    return std::string(std::max(0, int(cells - str.size())), ' ');
  }

  std::function<void(Model*)> getSolutionObserver() {
    return NewFeasibleSolutionObserver([&](const CpSolverResponse& r) {
      Schedule schedule;

      // LOG(INFO) << "Solution " << num_solutions;

      double scale = p.timesGCD / 3600. / p.float2int;
      auto F = [&](auto x) { return ceil(1000 * x * scale) / 1000.; };
      auto Vi = [&](string a, vector<int> i) { return SolutionIntegerValue(r, vm.i(a, i)); };
      auto Vb = [&](string a, vector<int> i) { return SolutionIntegerValue(r, vm.b(a, i)); };
      auto Ve = [&](string a, vector<int> i) { return SolutionIntegerValue(r, vm.e(a, i)); };

      for (auto machine : {IndustryType::REACTION, IndustryType::MANUFACTURING}) {
        if (p.machines.contains(machine)) {

          // if (machine == IndustryType::REACTION) {
          //   LOG(INFO) << "    Reactions";
          // } else {
          //   LOG(INFO) << "    Manufacturing";
          // }

          for (int b = 0; b < p.maxNumBatches[machine]; ++b) {
            Batch batch;
            int64_t batchTime = Vi(machine2str.at(machine) + "BatchTimes", {b});
            int64_t startTime = Ve(machine2str.at(machine) + "StartTimes", {b});
            batch.startTime = Util::ceilDiv(startTime * p.timesGCD, p.float2int);
            // if (batchTime == 0) {
            //   LOG(INFO) << "\tBatch:" << b << "is empty" << endl;
            // } else {
            //   LOG(INFO) << "\tBatch:" << b << getSpacing(b, 4) << "Start:" << F(startTime) << getSpacing(F(startTime), 10)
            //             << "End:" << F(startTime + batchTime) << getSpacing(F(startTime + batchTime), 10) << "Duration:" << F(batchTime)
            //             << endl;
            // }
            for (int k : p.jobTypes) {
              if (p.job2machine[k] == machine) {
                int64_t s = Vi("slots", {k, b});
                if (s == 0) {
                  continue;
                }
                int64_t runs = Vi("runs", {k, b});
                int64_t slots = Vi("slots", {k, b});
                int64_t time = Ve("timeOfJobTypeOnBatch", {k, b});
                // LOG(INFO) << "\t" << k << getSpacing(k, 10) << "  r:" << runs << getSpacing(runs, 10) << "   s:" << s << getSpacing(s, 10)
                //           << "t:" << F(time) << getSpacing(F(time), 10) << std::endl;
                batch.items[k] = BatchItem(runs, slots, Util::ceilDiv(time * p.timesGCD, p.float2int));
              }
            }
            if (batch.items.size() > 0) {
              schedule.machine2batches[machine].push_back(batch);
            }
          }
          // LOG(INFO) << endl;
        }
      }
      int64_t maxT = Vi("scheduleCompletionTime", {0});
      schedule.time = double(Util::ceilDiv(maxT * p.timesGCD, p.float2int));
      // int64_t ub = p.completionTimeUpperBound / 8;
      // int64_t lb = p.completionTimeLowerBound;
      // LOG(INFO) << "\t  - upperbound : " << ub * scale << endl;
      // LOG(INFO) << "\t  - sched time : " << maxT * scale << endl;
      // LOG(INFO) << "\t  - lowerbound : " << lb * scale << endl;
      // if (lb > 0) {
      //  LOG(INFO) << "\t  - time/lb    : " << (maxT / double(lb)) << endl;
      //}
      // if (ub > 0) {
      //  LOG(INFO) << "\t  - 1-time/ub  : " << (1.0 - maxT / double(ub)) << endl;
      //}
      // LOG(INFO) << "\t  - real time  : " << r.wall_time() << endl;
      // LOG(INFO) << endl;
      // num_solutions++;

      most_recent_schedule = schedule;
      callback(schedule);
    });
  }
};