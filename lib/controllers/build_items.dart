import 'dart:math';

import 'package:eve_reactor/chain_processor.dart';
import 'package:flutter/material.dart';

import '../models/build_items.dart';
import '../persistence/persistence.dart';

class BuildItemsController extends BuildItems with ChangeNotifier {
  final Persistence _persistence;

  bool _shouldNotifyAndSetCache = true;

  BuildItemsController(this._persistence) {
    chainProcessor = ChainProcessor((_) async => await _updateCache(), maxFrequency: const Duration(milliseconds: 500));
  }

  Future<void> loadFromCache() async {
    _shouldNotifyAndSetCache = false;
    final targets2runs = await _persistence.getTargets2Runs();
    for (var entry in targets2runs.entries) {
      addTarget(entry.key, entry.value);
    }
    final shouldBuild = await _persistence.getShouldBuild();
    for (var entry in shouldBuild.entries) {
      setShouldBuild(entry.key, entry.value);
    }
    final bpOps = await _persistence.getBpOptions();
    for (var entry in bpOps.entries) {
      setME(entry.key, entry.value.ME);
      setTE(entry.key, entry.value.TE);
      setMaxRuns(entry.key, entry.value.maxNumRuns);
      setMaxBPs(entry.key, entry.value.maxNumBPs);
    }
    _shouldNotifyAndSetCache = true;
    notifyListeners();
  }

  late final ChainProcessor chainProcessor;
  Future<void> _updateCache() async {
    await _persistence.setTargets2Runs(getTarget2RunsCopy());
    await _persistence.setShouldBuild(getAllShouldBuildCopy());
    await _persistence.setBpOptions(getBpOptionsCopy());
  }

  Future<void> _notify() async {
    if (_shouldNotifyAndSetCache) {
      chainProcessor.compute();
      notifyListeners();
    }
  }

  @override
  void addTarget(int tid, int runs) {
    super.addTarget(tid, runs);
    _notify();
  }

  @override
  void removeTarget(int tid) {
    super.removeTarget(tid);
    _notify();
  }

  @override
  void setRuns(int tid, int runs) {
    runs = max(1, runs);
    super.setRuns(tid, runs);
    _notify();
  }

  @override
  void setME(int tid, int? ME) {
    super.setME(tid, ME);
    _notify();
  }

  @override
  void setTE(int tid, int? TE) {
    super.setTE(tid, TE);
    _notify();
  }

  @override
  void setMaxRuns(int tid, int? maxRuns) {
    if (maxRuns == 0) {
      maxRuns = null;
    }
    super.setMaxRuns(tid, maxRuns);
    _notify();
  }

  @override
  void setMaxBPs(int tid, int? maxBPs) {
    if (maxBPs == 0) {
      maxBPs = null;
    }
    super.setMaxBPs(tid, maxBPs);
    _notify();
  }

  @override
  void setShouldBuild(int tid, bool build) {
    super.setShouldBuild(tid, build);
    _notify();
  }
}
