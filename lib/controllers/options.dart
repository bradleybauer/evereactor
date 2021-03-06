import 'dart:math';

import 'package:flutter/material.dart';

import '../chain_processor.dart';
import '../models/bonus_type.dart';
import '../models/industry_type.dart';
import '../models/options.dart';
import '../persistence/persistence.dart';
import '../sde.dart';
import '../strings.dart';

class OptionsController extends Options with ChangeNotifier {
  final Persistence _persistence;

  OptionsController(this._persistence, Strings strings) {
    chainProcessor = ChainProcessor((_) async => await _updateCache(), maxFrequency: const Duration(milliseconds: 500));
    strings.addListener(notify);
  }

  Future<void> loadFromCache() async {
    Options? options = await _persistence.getOptions();
    if (options != null) {
      super.setReactionSlots(options.getReactionSlots());
      super.setManufacturingSlots(options.getManufacturingSlots());
      super.setME(options.getME());
      super.setTE(options.getTE());
      super.setMaxNumBlueprints(options.getMaxNumBlueprints());
      super.setReactionSystemCostIndex(options.getReactionSystemCostIndex());
      super.setManufacturingSystemCostIndex(options.getManufacturingSystemCostIndex());
      super.setSalesTaxPercent(options.getSalesTaxPercent());
      super.setManufacturingStructure(options.getManufacturingStructure());
      super.setReactionStructure(options.getReactionStructure());
    }
    (await _persistence.getSkills2Level()).forEach((tid, level) {
      super.setSkillLevel(tid, level);
    });
    (await _persistence.getManufacturingRigs()).forEach((tid) {
      super.addManufacturingRig(tid);
    });
    (await _persistence.getReactionRigs()).forEach((tid) {
      super.addReactionRig(tid);
    });
    notifyListeners();
  }

  late final ChainProcessor chainProcessor;

  Future<void> _updateCache() async {
    await _persistence.setOptions(this);
    await _persistence.setSkills2Level(getSkill2LevelCopy());
    await _persistence.setManufacturingRigs(getSelectedManufacturingRigs().map((e) => e.tid).toSet());
    await _persistence.setReactionRigs(getSelectedReactionRigs().map((e) => e.tid).toSet());
  }

  void notify() {
    chainProcessor.compute();
    notifyListeners();
  }

  @override
  void setAllSkillLevels(int level) {
    super.setAllSkillLevels(level);
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
    return skills.map((e) => SkillsData(e.key, Strings.get(e.value.nameLocalizations), super.getSkillLevel(e.key))).toList();
  }

  @override
  void setSkillLevel(int tid, int level) {
    level = max(1, min(level, 5));
    super.setSkillLevel(tid, level);
    notify();
  }

  @override
  void setReactionSlots(int slots) {
    slots = max(1, min(slots, 5000));
    super.setReactionSlots(slots);
    notify();
  }

  @override
  void setManufacturingSlots(int slots) {
    slots = max(1, min(slots, 5000));
    super.setManufacturingSlots(slots);
    notify();
  }

  @override
  void setME(int ME) {
    ME = min(20, max(0, ME));
    super.setME(ME);
    notify();
  }

  @override
  void setTE(int TE) {
    TE = min(20, max(0, TE));
    super.setTE(TE);
    notify();
  }

  @override
  void setMaxNumBlueprints(int maxNumBps) {
    maxNumBps = min(999, max(1, maxNumBps));
    super.setMaxNumBlueprints(maxNumBps);
    notify();
  }

  @override
  void setReactionSystemCostIndex(double index) {
    index = min(50, max(0, index)); // allow cost index to be 0 so the input field works better.
    super.setReactionSystemCostIndex(index);
    notify();
  }

  @override
  void setManufacturingSystemCostIndex(double index) {
    index = min(50, max(0, index));
    super.setManufacturingSystemCostIndex(index);
    notify();
  }

  @override
  void setSalesTaxPercent(double tax) {
    tax = min(10, max(0, tax));
    super.setSalesTaxPercent(tax);
    notify();
  }

  Iterable<StructureData> getManufacturingStructures() => SDE.structures.entries
      .where((e) => e.value.industryType == IndustryType.MANUFACTURING)
      .map((e) => StructureData(e.key, Strings.get(e.value.nameLocalizations)));

  Iterable<StructureData> getReactionStructures() => SDE.structures.entries
      .where((e) => e.value.industryType == IndustryType.REACTION)
      .map((e) => StructureData(e.key, Strings.get(e.value.nameLocalizations)));

  String getSelectedManufacturingStructureName() => Strings.get(SDE.structures[super.getManufacturingStructure()]!.nameLocalizations);

  int getSelectedManufacturingStructureTid() => super.getManufacturingStructure();

  @override
  void setManufacturingStructure(int tid) {
    super.setManufacturingStructure(tid);
    notify();
  }

  String getSelectedReactionStructureName() => Strings.get(SDE.structures[super.getReactionStructure()]!.nameLocalizations);

  int getSelectedReactionStructureTid() => super.getReactionStructure();

  @override
  void setReactionStructure(int tid) {
    super.setReactionStructure(tid);
    notify();
  }

  List<RigData> getAvailableManufacturingRigs() {
    final selectedRigs = super.getManufacturingRigs().toSet();
    return SDE.rigs.entries
        .where((e) => e.value.industryType == IndustryType.MANUFACTURING && !selectedRigs.contains(e.key))
        .map((e) => RigData(e.key, Strings.get(e.value.nameLocalizations).replaceFirst('Standup ', '')))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<RigData> getAvailableReactionRigs() {
    final selectedRigs = super.getReactionRigs().toSet();
    return SDE.rigs.entries
        .where((e) => e.value.industryType == IndustryType.REACTION && !selectedRigs.contains(e.key))
        .map((e) => RigData(e.key, Strings.get(e.value.nameLocalizations).replaceFirst('Standup ', '')))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<RigData> getSelectedManufacturingRigs() =>
      super.getManufacturingRigs().map((e) => RigData(e, Strings.get(SDE.rigs[e]!.nameLocalizations))).toList();

  @override
  void addManufacturingRig(int tid) {
    super.addManufacturingRig(tid);
    notify();
  }

  @override
  void removeManufacturingRig(int i) {
    super.removeManufacturingRig(i);
    notify();
  }

  List<RigData> getSelectedReactionRigs() =>
      super.getReactionRigs().map((e) => RigData(e, Strings.get(SDE.rigs[e]!.nameLocalizations))).toList();

  @override
  void addReactionRig(int tid) {
    super.addReactionRig(tid);
    notify();
  }

  @override
  void removeReactionRig(int i) {
    super.removeReactionRig(i);
    notify();
  }

  double? getManufacturingCostBonus() => SDE.structures[super.getManufacturingStructure()]!.bonuses[BonusType.COST];

  List<LangData> getLangs() => Strings.langNames.entries.map((e) => LangData(e.key, Strings.get(Strings.langNames[e.key]!))).toList();

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
