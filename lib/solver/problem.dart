import 'package:fraction/fraction.dart';

import '../models/industry_type.dart';
import '../models/inventory.dart';
import '../sde_extra.dart';

import 'schedule.dart';

class Problem {
  final Map<int, int> runsExcess; // buildItems
  final Set<int> tids; // buildItems
  final Map<int, Map<int, int>> dependencies; // build
  final Inventory inventory;
  final Map<IndustryType, int> maxNumSlotsOfMachine; // buildOptions
  final Map<int, int> maxNumSlotsOfJob; // buildItems // limits number of blueprints used for a job type
  final Map<int, int> maxNumRunsPerSlotOfJob; // buildItems // limits number of runs on any blueprint for a job type
  final Map<int, Fraction> jobMaterialBonus; // buildItems & buildOptions
  final Map<int, Fraction> jobTimeBonus; // buildItems & buildOptions
  final int float2int; // idk yet, ircc can be dynamically computed

  // functions of constructor args
  late final Set<IndustryType> machines;
  late final Map<int, IndustryType> job2machine;
  bool M2DependsOnM1 = false;
  late final Map<int,int> timePerRun;
  late final Map<int,int> madePerRun;

  Map<IndustryType, int> minNumBatches = {};
  Map<IndustryType, int> maxNumBatches = {};
  Map<int,int> maxNumRuns = {};
  Map<int,int> minNumRuns = {};
  int completionTimeUpperBound = -1;
  int completionTimeLowerBound = -1;
  Map<int,List<int>> inverseDependencies = {};
  int timesGCD = -1;

  Schedule? approximation;

  Problem({
    required this.runsExcess,
    required this.tids,
    required this.dependencies,
    required this.inventory,
    required this.maxNumSlotsOfMachine,
    required this.maxNumSlotsOfJob,
    required this.maxNumRunsPerSlotOfJob,
    required this.jobMaterialBonus,
    required this.jobTimeBonus,
    this.float2int = 1000,
  }) {
    job2machine = Map.fromEntries(tids.map((tid) => MapEntry(tid, SD.industryType(tid))));
    machines = tids.map((tid) => SD.industryType(tid)).toSet();

    // for each item, not all its dependencies have the same machine as the item
    dependencies.forEach((pid, child2qty) {
      child2qty.forEach((cid, value) {
        if (job2machine[pid] != job2machine[cid]) {
          M2DependsOnM1 = true;
        }
      });
    });

    timePerRun = Map.fromEntries(tids.map((e) => MapEntry(e, SD.timePerRun(e))));
    madePerRun = Map.fromEntries(tids.map((e) => MapEntry(e, SD.numProducedPerRun(e))));
  }
}
