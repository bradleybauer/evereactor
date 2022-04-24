import 'dart:math';

import 'package:flutter/material.dart';

import '../models/options.dart';
import '../sde.dart';
import '../strings.dart';
import 'market.dart';

class OptionsAdapter with ChangeNotifier {
  final Options _options = Options();
  final MarketAdapter _market;

  OptionsAdapter(this._market, Strings strings) {
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
    index = min(50, max(0.1, index));
    _options.setReactionSystemCostIndex(index);
    notify();
  }

  double getManufacturingSystemCostIndex() => _options.getManufacturingSystemCostIndex();

  void setManufacturingSystemCostIndex(double index) {
    index = min(50, max(0.1, index));
    _options.setManufacturingSystemCostIndex(index);
    notify();
  }

  double getSalesTax() => _options.getSalesTax();

  void setSalesTax(double tax) {
    tax = min(10, max(0, tax));
    _options.setSalesTax(tax);
    notify();
  }
}

class SkillsData {
  final int tid;
  final String name;
  final int level;

  const SkillsData(this.tid, this.name, this.level);
}
