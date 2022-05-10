import '../sde_extra.dart';
import 'blueprint_options.dart';

// Stores per-item information about the build.
class BuildItems {
  // The 'targets' (items user has requested to be built) and how many runs to build.
  final Map<int, int> _tid2runs = {};

  // The blueprint options for all items involved in the build.
  final Map<int, BpOptions> _tid2bpOps = {};

  // Whether the user has selected to build or buy the given intermediate item.
  final Map<int, bool> _tid2shouldBuild = {};

  // Add a number of runs of type id to the build.
  void addTarget(int tid, int runs) {
    _tid2runs.update(tid, (existingRuns) => existingRuns + runs, ifAbsent: () => runs);
    restrict();
  }

  void removeTarget(int tid) {
    _tid2runs.remove(tid);
    restrict();
  }

  // Ensures that we do not hold onto more information than necessary.
  void restrict() {
    final intermediates = _getItemsWithBuildBuyOptions();

    // Update build buy options
    // Only intermediates have build/buy options
    for (int tid in _tid2shouldBuild.keys.toList()) {
      if (!intermediates.contains(tid)) {
        _tid2shouldBuild.remove(tid);
      }
    }
    for (int tid in intermediates) {
      if (!_tid2shouldBuild.containsKey(tid)) {
        _tid2shouldBuild[tid] = true;
      }
    }

    final targets = _tid2runs.keys.toSet();
    final itemsInBuild = getItemsInBuild();
    // Update blueprint options
    for (int tid in _tid2bpOps.keys.toList()) {
      // every id in tid2bpOps should be associated with a target or an intermediate
      if (!targets.contains(tid) && !itemsInBuild.contains(tid)) {
        _tid2bpOps.remove(tid);
      }
    }
    // if a non tech 1 item does not have a BpOps yet then give it a default with appropriate ME&TE
    for (int tid in targets.union(itemsInBuild)) {
      if (!SD.isTech1(tid)) {
        if (!_tid2bpOps.containsKey(tid)) {
          if (SD.isTech2(tid)) {
            _tid2bpOps[tid] = const BpOptions(ME: 3, TE: 2);
          } else {
            _tid2bpOps[tid] = const BpOptions(ME: 0, TE: 0);
          }
        }
      }
    }
    // Add missing IDs
    // Every target and intermediate has a BpOptions
    for (int tid in targets) {
      if (!_tid2bpOps.containsKey(tid)) {
        _tid2bpOps[tid] = const BpOptions();
      }
    }
    // Intermediates have build/buy option
    for (int tid in itemsInBuild) {
      if (!_tid2bpOps.containsKey(tid)) {
        _tid2bpOps[tid] = const BpOptions();
      }
    }
  }

  int? _getDefaultME(int tid) {
    if (!SD.isTech1(tid)) {
      if (SD.isTech2(tid)) {
        return 3;
      } else {
        return 0;
      }
    }
    return null;
  }

  int getNumberOfTargets() => _tid2runs.length;

  Set<int> getTargetsIDs() => _tid2runs.keys.toSet();

  int getTargetRuns(int id) => _tid2runs[id]!;

  Map<int, int> getTarget2RunsCopy() => {..._tid2runs};

  Set<int> getItemsWithBuildBuyOptions() => _tid2shouldBuild.keys.toSet();

  // Return ids of items that have build/buy options
  Set<int> _getItemsWithBuildBuyOptions() {
    final result = <int>{};
    for (int tid in _tid2runs.keys) {
      result.addAll(_getDependencies(tid, true));
    }
    return result;
  }

  Set<int> _getDependencies(int pid, bool includeItemsSetToBuy) {
    final result = <int>{};
    for (int cid in SD.materials(pid).keys) {
      if (getShouldBuildChildOfParent(pid, cid, excludeItemsSetToBuy: !includeItemsSetToBuy)) {
        result.add(cid);
        if (getShouldBuild(cid)) {
          result.addAll(_getDependencies(cid, includeItemsSetToBuy));
        }
      }
    }
    return result;
  }

  // Given the parent and child, returns whether child should be built.
  bool getShouldBuildChildOfParent(int pid, int cid, {required bool excludeItemsSetToBuy}) {
    assert(SD.isBuildable(pid));
    if (excludeItemsSetToBuy) {
      return SD.isBuildable(cid) && !SD.isWrongIndyType(pid, cid) && getShouldBuild(cid);
    } else {
      return SD.isBuildable(cid) && !SD.isWrongIndyType(pid, cid);
    }
  }

  // Return ids of all items that could be built in the build. (inventory may still elide building of items)
  Set<int> getItemsInBuild() => _tid2shouldBuild.keys.where((k) => _tid2shouldBuild[k]!).toSet().union(_tid2runs.keys.toSet());

  void setRuns(int tid, int runs) => _tid2runs[tid] = runs;

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
      assert(false);
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

  int? getME(int tid) => _tid2bpOps[tid]?.ME ?? _getDefaultME(tid);

  int? getTE(int tid) => _tid2bpOps[tid]?.TE;

  int? getMaxRuns(int tid) => _tid2bpOps[tid]?.maxNumRuns;

  int? getMaxBPs(int tid) => _tid2bpOps[tid]?.maxNumBPs;

  void setShouldBuild(int tid, bool build) {
    _tid2shouldBuild[tid] = build;
    restrict();
  }

  // Returns whether the buildItems thinks the item should be built... Returns true if it does not have an 'opinion'.
  // If an item is set to buy then it should not be in the material list for any other item.
  bool getShouldBuild(int tid) => !_tid2shouldBuild.containsKey(tid) || _tid2shouldBuild[tid]!;

  Map<int, bool> getAllShouldBuildCopy() => {..._tid2shouldBuild};

  Map<int, BpOptions> getBpOptionsCopy() => {..._tid2bpOps};
}
