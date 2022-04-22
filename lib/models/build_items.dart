import 'blueprint_options.dart';

// Stores per-item level information about the build
// Computes the build dependency map using the sde.
class BuildItems {
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

  int getNumberOfTargets() => _tid2runs.length;

  List<int> getTargetsIds() => _tid2runs.keys.toList(growable: false);

  int getTargetRuns(int id) => _tid2runs[id]!;

  Map<int, int> getTarget2Runs() => _tid2runs;

  // Returns whether the buildItems thinks the item should be built... Returns true if it does not have an 'opinion'.
  // If an item is set to buy then it should not be in the material list for any other item.
  bool shouldBuild(int tid) => !_tid2shouldBuild.containsKey(tid) || _tid2shouldBuild[tid]!;

  void setRuns(int tid, int runs) => _tid2runs.update(tid, (value) => runs, ifAbsent: () => runs);

  void setME(int tid, int? ME) {
    if (!_tid2bpOps.containsKey(tid)) {
      _tid2bpOps[tid] = BPOptions(ME: ME);
    }
    _tid2bpOps[tid] = _tid2bpOps[tid]!.copyWithME(ME);
  }

  void setTE(int tid, int? TE) {
    if (!_tid2bpOps.containsKey(tid)) {
      _tid2bpOps[tid] = BPOptions(TE: TE);
    }
    _tid2bpOps[tid] = _tid2bpOps[tid]!.copyWithTE(TE);
  }

  void setMaxRuns(int tid, int? maxRuns) {
    if (!_tid2bpOps.containsKey(tid)) {
      _tid2bpOps[tid] = BPOptions(maxNumRuns: maxRuns);
    }
    _tid2bpOps[tid] = _tid2bpOps[tid]!.copyWithRuns(maxRuns);
  }

  void setMaxBPs(int tid, int? maxBPs) {
    if (!_tid2bpOps.containsKey(tid)) {
      _tid2bpOps[tid] = BPOptions(maxNumBPs: maxBPs);
    }
    _tid2bpOps[tid] = _tid2bpOps[tid]!.copyWithBPs(maxBPs);
  }

  int? getME(int tid) => _tid2bpOps[tid]?.ME;

  int? getTE(int tid) => _tid2bpOps[tid]?.TE;

  int? getMaxRuns(int tid) => _tid2bpOps[tid]?.maxNumRuns;

  int? getMaxBPs(int tid) => _tid2bpOps[tid]?.maxNumBPs;
}
