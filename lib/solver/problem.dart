// TODO max number of runs per slot depends on all time efficiency modifiers
//      maybe will not worry about this. in most real use cases this will not come into effect... I hope.
//      at least it will not for my use cases, which is producing tons of ships and all the intermediates in excess.
import '../models/industry_type.dart';
import '../models/inventory.dart';
import '../sde_extra.dart';

class Problem {
  final Map<int, int> runsExcess; // buildItems
  final Set<int> tids; // buildItems
  final Map<int, Map<int, int>> dependencies; // build
  final Inventory inventory;
  final Map<IndustryType, int> maxNumSlotsOfMachine; // buildOptions
  final Map<int, int> maxNumSlotsOfJob; // buildItems // limits number of blueprints used for a job type
  final Map<int, int> maxNumRunsPerSlotOfJob; // buildItems // limits number of runs on any blueprint for a job type
  final Map<int, double> jobMaterialBonus; // buildItems & buildOptions
  final Map<int, double> jobTimeBonus; // buildItems & buildOptions
  final int float2int; // idk yet, ircc can be dynamically computed

  // functions of constructor args
  late final Set<IndustryType> machines;
  late final Map<int, IndustryType> job2machine;
  late final bool M2DependsOnM1;

  int? minNumBatches;
  int? maxNumBatches;
  int? maxNumRuns;
  int? minNumRuns;
  int? completionTimeUpperBound;
  int? completionTimeLowerBound;
  int? inverseDependencies;
  int? timesGCD;

  // int? scheduleCompletionTime;
  // int? approximationBatches;
  // int? approximationTime;

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
    M2DependsOnM1 = !dependencies.entries
        .every((parent) => parent.value.entries.every((child) => job2machine[child.key] == job2machine[parent.key]));
  }
}
