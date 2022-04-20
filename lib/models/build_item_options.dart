import 'blueprint_options.dart';

// Stores per-item level information about the build
// Computes the build dependency map using the sde.
class BuildItemOptions {
  // The 'targets' (primary items built) and how many runs to build.
  final Map<int, int> _tid2runs = {};

  // The blueprint options for all items involved in the build.
  final Map<int, BPOptions> _tid2bpOps = {};

  // Whether we should build the given type id.
  final Map<int, bool> _tid2shouldBuild = {};

  // Add a number of runs of type id to the build.
  void add(int tid, int runs) {
    _tid2runs.update(tid, (existingRuns) => existingRuns + runs, ifAbsent: () => runs);
  }

  // Remove all runs of type id from the build.
  void remove(int tid) {
    _tid2runs.remove(tid);
  }

  Map<int,List<int>> getDependencyMap() {return {};}
}
