import '../models/industry_type.dart';
import 'math.dart';
import 'sde.dart';

// Useful functions related to consuming SDE data
abstract class SD {
  // returns maxNumRunsOfRunsOnLines * timePerRun
  static int baseTime(int runs, int lines, int timePerRun) => ceilDiv(runs, lines) * timePerRun;

  static int timePerRun(int tid) => SDE.blueprints[tid]!.timePerRun;

  static int numProducedPerRun(int tid) => SDE.blueprints[tid]!.numProducedPerRun;

  static IndustryType industryType(int tid) => SDE.blueprints[tid]!.industryType;

  static Map<int, int> materials(int tid) => SDE.blueprints[tid]!.input2quantity;

  static bool isBuildable(int tid) => SDE.blueprints.containsKey(tid);

  static String enName(int tid) => SDE.items[tid]!.nameLocalizations['en']!;
}
