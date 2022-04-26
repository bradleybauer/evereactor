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

  static bool isTech1(int tid) {
    final lvl = SDE.blueprints[tid]?.techLevel;
    // components do not have 'techLevel' in the sde, so... assume true here..
    // also some 'faction' ships like ikitursa and drekavac are thought of as T1 by the SDE.
    // the fact the SDE does not give a field for whether an item can be built from a BPO
    // in game (excluding t2 bpo) is stupid as fuck.
    // I try to deal with edencom & trig ships in the sde_extractor... but there may be other edge cases.
    var ret = true;
    if (lvl != null) {
      ret = lvl == 1;
    }
    return ret;
  }

  static bool isTech2(int tid) {
    final lvl = SDE.blueprints[tid]?.techLevel;
    if (lvl == null) {
      return false;
    }
    return lvl == 2;
  }
}
