import 'blueprint_options.dart';

// Stores per-item level information about the build
// Computes the build dependency map using the sde.
class BuildItems {
  // The 'targets' (primary items built) and how many runs to build.
  final Map<int, int> _tid2runs = {};

  // The blueprint options for all items involved in the build.
  final Map<int, BpOptions> _tid2bpOps = {};

  // Whether we should build the given type id.
  final Map<int, bool> _tid2shouldBuild = {};

  // Add a number of runs of type id to the build.
  void addTarget(int tid, int runs) {
    _tid2runs.update(tid, (existingRuns) => existingRuns + runs, ifAbsent: () => runs);
  }

  // Remove all runs of type id from the build.
  void removeTarget(int tid) {
    _tid2runs.remove(tid);
  }

  // Ensures that we do not hold onto old items in the containers.
  void restrict(Set<int> targets, Set<int> intermediates) {
    // Remove stray IDs
    for (int tid in _tid2bpOps.keys.toList()) {
      // any id in tid2bpOps should be associated with a target or an intermediate
      if (!targets.contains(tid) && !intermediates.contains(tid)) {
        _tid2bpOps.remove(tid);
      }
    }
    // Only intermediates have build/buy options
    for (int tid in _tid2shouldBuild.keys.toList()) {
      if (!intermediates.contains(tid)) {
        _tid2shouldBuild.remove(tid);
      }
    }

    // Add missing IDs
    // Every target and intermediate has a BpOptions
    for (int tid in targets) {
      if (!_tid2bpOps.containsKey(tid)) {
        _tid2bpOps[tid] = const BpOptions();
      }
    }
    for (int tid in intermediates) {
      if (!_tid2bpOps.containsKey(tid)) {
        _tid2bpOps[tid] = const BpOptions();
      }
    }
    // Intermediates have build/buy option
    for (int tid in intermediates) {
      if (!_tid2shouldBuild.containsKey(tid)) {
        _tid2shouldBuild[tid] = true;
      }
    }
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
      _tid2bpOps[tid] = BpOptions(ME: ME);
    }
    _tid2bpOps[tid] = _tid2bpOps[tid]!.copyWithME(ME);
  }

  void setTE(int tid, int? TE) {
    if (!_tid2bpOps.containsKey(tid)) {
      _tid2bpOps[tid] = BpOptions(TE: TE);
    }
    _tid2bpOps[tid] = _tid2bpOps[tid]!.copyWithTE(TE);
  }

  void setMaxRuns(int tid, int? maxRuns) {
    if (!_tid2bpOps.containsKey(tid)) {
      _tid2bpOps[tid] = BpOptions(maxNumRuns: maxRuns);
    }
    _tid2bpOps[tid] = _tid2bpOps[tid]!.copyWithRuns(maxRuns);
  }

  void setMaxBPs(int tid, int? maxBPs) {
    if (!_tid2bpOps.containsKey(tid)) {
      _tid2bpOps[tid] = BpOptions(maxNumBPs: maxBPs);
    }
    _tid2bpOps[tid] = _tid2bpOps[tid]!.copyWithBPs(maxBPs);
  }

  int? getME(int tid) => _tid2bpOps[tid]?.ME;

  int? getTE(int tid) => _tid2bpOps[tid]?.TE;

  int? getMaxRuns(int tid) => _tid2bpOps[tid]?.maxNumRuns;

  int? getMaxBPs(int tid) => _tid2bpOps[tid]?.maxNumBPs;

  void setShouldBuild(int tid, bool build) {
    _tid2shouldBuild[tid] = build;
  }

  bool getShouldBuild(int tid) {
    if (_tid2shouldBuild.containsKey(tid)) {
      return _tid2shouldBuild[tid]!;
    }
    assert(false);
    return false;
  }
}
