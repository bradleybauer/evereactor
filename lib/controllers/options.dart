import 'dart:math';

import 'package:EveIndy/models/industry_type.dart';
import 'package:flutter/material.dart';

import '../models/options.dart';
import '../sde.dart';
import '../strings.dart';
import 'market.dart';

class OptionsController with ChangeNotifier {
  final Options _options = Options();
  final MarketController _market;

  OptionsController(this._market, Strings strings) {
    strings.addListener(() {
      notify();
    });
  }

  void notify() {
    notifyListeners();
  }

  void setAllSkillLevels(int level) {
    _options.setAllSkillLevels(level);
    notify();
  }

  List<SkillsData> getSkills() {
    final skills = SDE.skills.entries.toList(growable: false)
      ..sort((a, b) {
        // first sort by IndustryType (reactions first) then by marketGroupID
        return (a.value.industryType.index < b.value.industryType.index
            ? -1
            : a.value.industryType.index == b.value.industryType.index
                ? (a.value.marketGroupID < b.value.marketGroupID
                    ? -1
                    : a.value.marketGroupID == b.value.marketGroupID
                        ? 0
                        : 1)
                : 1);
      });
    return skills
        .map((e) => SkillsData(e.key, Strings.get(e.value.nameLocalizations), _options.getSkillLevel(e.key)))
        .toList();
  }

  void setSkillLevel(int tid, int level) {
    level = max(1, min(level, 5));
    _options.setSkillLevel(tid, level);
    notify();
  }

  int getSkillLevel(int tid) => _options.getSkillLevel(tid);

  int getReactionSlots() => _options.getReactionSlots();

  void setReactionSlots(int slots) {
    slots = max(1, min(slots, 5000));
    _options.setReactionSlots(slots);
    notify();
  }

  int getManufacturingSlots() => _options.getManufacturingSlots();

  void setManufacturingSlots(int slots) {
    slots = max(1, min(slots, 5000));
    _options.setManufacturingSlots(slots);
    notify();
  }

  int getME() => _options.getME();

  void setME(int ME) {
    ME = min(20, max(0, ME));
    _options.setME(ME);
    notify();
  }

  int getTE() => _options.getTE();

  void setTE(int TE) {
    TE = min(20, max(0, TE));
    _options.setTE(TE);
    notify();
  }

  int getMaxNumBlueprints() => _options.getMaxNumBlueprints();

  void setMaxNumBlueprints(int maxNumBps) {
    maxNumBps = min(999, max(1, maxNumBps));
    _options.setMaxNumBlueprints(maxNumBps);
    notify();
  }

  double getReactionSystemCostIndex() => _options.getReactionSystemCostIndex();

  void setReactionSystemCostIndex(double index) {
    index = min(50, max(0, index)); // allow cost index to be 0 so the input field works better.
    _options.setReactionSystemCostIndex(index);
    notify();
  }

  double getManufacturingSystemCostIndex() => _options.getManufacturingSystemCostIndex();

  void setManufacturingSystemCostIndex(double index) {
    index = min(50, max(0, index));
    _options.setManufacturingSystemCostIndex(index);
    notify();
  }

  double getSalesTaxPercent() => _options.getSalesTaxPercent();

  void setSalesTax(double tax) {
    tax = min(10, max(0, tax));
    _options.setSalesTax(tax);
    notify();
  }

  Iterable<StructureData> getManufacturingStructures() => SDE.structures.entries
      .where((e) => e.value.industryType == IndustryType.MANUFACTURING)
      .map((e) => StructureData(e.key, Strings.get(e.value.nameLocalizations)));

  Iterable<StructureData> getReactionStructures() => SDE.structures.entries
      .where((e) => e.value.industryType == IndustryType.REACTION)
      .map((e) => StructureData(e.key, Strings.get(e.value.nameLocalizations)));

  StructureData getManufacturingStructure() {
    int tid = _options.getManufacturingStructure();
    return StructureData(tid, Strings.get(SDE.structures[tid]!.nameLocalizations));
  }

  void setManufacturingStructure(int tid) {
    _options.setManufacturingStructure(tid);
    notify();
  }

  StructureData getReactionStructure() {
    int tid = _options.getReactionStructure();
    return StructureData(tid, Strings.get(SDE.structures[tid]!.nameLocalizations));
  }

  void setReactionStructure(int tid) {
    _options.setReactionStructure(tid);
    notify();
  }

  List<RigData> getManufacturingRigs() {
    final selectedRigs = _options.getManufacturingRigs().toSet();
    return SDE.rigs.entries
        .where((e) => e.value.industryType == IndustryType.MANUFACTURING && !selectedRigs.contains(e.key))
        .map((e) => RigData(e.key, Strings.get(e.value.nameLocalizations).replaceFirst('Standup ', '')))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<RigData> getReactionRigs() {
    final selectedRigs = _options.getReactionRigs().toSet();
    return SDE.rigs.entries
        .where((e) => e.value.industryType == IndustryType.REACTION && !selectedRigs.contains(e.key))
        .map((e) => RigData(e.key, Strings.get(e.value.nameLocalizations).replaceFirst('Standup ', '')))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<RigData> getSelectedManufacturingRigs() =>
      _options.getManufacturingRigs().map((e) => RigData(e, Strings.get(SDE.rigs[e]!.nameLocalizations))).toList();

  void addManufacturingRig(int tid) {
    _options.addManufacturingRig(tid);
    notify();
  }

  void removeManufacturingRig(int i) {
    _options.removeManufacturingRig(i);
    notify();
  }

  List<RigData> getSelectedReactionRigs() =>
      _options.getReactionRigs().map((e) => RigData(e, Strings.get(SDE.rigs[e]!.nameLocalizations))).toList();

  void addReactionRig(int tid) {
    _options.addReactionRig(tid);
    notify();
  }

  void removeReactionRig(int i) {
    _options.removeReactionRig(i);
    notify();
  }

  int getNumSelectedManufacturingRigs() => _options.getNumSelectedManufacturingRigs();

  int getNumSelectedReactionRigs() => _options.getNumSelectedReactionRigs();

  List<LangData> getLangs() =>
      Strings.langNames.entries.map((e) => LangData(e.key, Strings.get(Strings.langNames[e.key]!))).toList();

  String getLangName() => Strings.get(Strings.langNames[Strings.getLang()]!);
}

class SkillsData {
  final int tid;
  final String name;
  final int level;

  const SkillsData(this.tid, this.name, this.level);
}

class StructureData {
  final int tid;
  final String name;

  StructureData(this.tid, this.name);
}

class RigData {
  final int tid;
  final String name;

  RigData(this.tid, this.name);
}

class LangData {
  final String label;
  final String name;

  LangData(this.label, this.name);
}
