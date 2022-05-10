import 'dart:math';

import 'package:fraction/fraction.dart';

import '../sde.dart';
import '../solver/schedule.dart';
import 'controllers/build_items.dart';
import 'controllers/options.dart';
import 'math.dart';
import 'models/blueprint.dart';
import 'models/bonus_type.dart';
import 'models/industry_type.dart';
import 'models/rig.dart';
import 'sde_extra.dart';

int getNumNeeded(int runs, int slots, int childPerParent, Fraction bonus) {
  final remainder = runs % slots;
  final runsFloor = runs ~/ slots;
  final runsCeil = runsFloor + 1;
  return max(runsFloor, ceilDiv(childPerParent * runsFloor * bonus.numerator, bonus.denominator)) *
          (slots - remainder) +
      max(runsCeil, ceilDiv(childPerParent * runsCeil * bonus.numerator, bonus.denominator)) * remainder;
}

double getApproxNumNeeded(int runs, int childPerParent, Fraction bonus) {
  return max(runs.toDouble(), (childPerParent * runs * bonus.numerator / bonus.denominator));
}

Fraction getMaterialBonusMemoized(
    int tid, OptionsController options, BuildItemsController buildItems, Map<int, Fraction> memo) {
  if (memo.containsKey(tid)) {
    return memo[tid]!;
  }
  final matBonus = getMaterialBonus(tid, options, buildItems);
  memo[tid] = matBonus;
  return matBonus;
}

Fraction getMaterialBonus(int tid, OptionsController options, BuildItemsController buildItems) {
  final bp = SDE.blueprints[tid]!;
  switch (bp.industryType) {
    case IndustryType.REACTION:
      return _getReactionMaterialBonus(tid, bp, options);
    case IndustryType.MANUFACTURING:
      return _getManufacturingMaterialBonus(tid, bp, options, buildItems);
  }
}

Fraction _getManufacturingMaterialBonus(
    int tid, Blueprint bp, OptionsController options, BuildItemsController buildItems) {
  var ret = 1.toFraction();

  // structures
  final structure = SDE.structures[options.getSelectedManufacturingStructureTid()]!;
  if (structure.bonuses.containsKey(BonusType.MATERIAL)) {
    ret *= structure.bonuses[BonusType.MATERIAL]!.toFraction();
  }

  // rigs
  ret *= getRigBonus(tid, options.getSelectedManufacturingRigs().map((e) => e.tid), BonusType.MATERIAL);

  // blueprint me settings
  ret *= 1.toFraction() - Fraction(buildItems.getME(tid) ?? options.getME(), 100);

  return ret.reduce();
}

// only rigs affect reaction ME
Fraction _getReactionMaterialBonus(int tid, Blueprint bp, OptionsController options) =>
    getRigBonus(tid, options.getSelectedReactionRigs().map((e) => e.tid), BonusType.MATERIAL).reduce();

Fraction getTimeBonus(int tid, OptionsController options, BuildItemsController buildItems) {
  // return 1.toFraction();
  final bp = SDE.blueprints[tid]!;
  switch (bp.industryType) {
    case IndustryType.REACTION:
      return _getReactionTimeBonus(tid, bp, options);
    case IndustryType.MANUFACTURING:
      return _getManufacturingTimeBonus(tid, bp, options, buildItems);
  }
}

Fraction _getManufacturingTimeBonus(int tid, Blueprint bp, OptionsController options, BuildItemsController buildItems) {
  var ret = 1.toFraction();

  // structure
  final structure = SDE.structures[options.getSelectedManufacturingStructureTid()]!;
  if (structure.bonuses.containsKey(BonusType.TIME)) {
    ret *= structure.bonuses[BonusType.TIME]!.toFraction();
  }

  // rigs
  ret *= getRigBonus(tid, options.getSelectedManufacturingRigs().map((e) => e.tid), BonusType.TIME);

  // skill
  ret *= getSkillBonus(tid, bp, options);

  // bp
  ret *= 1.toFraction() - Fraction(buildItems.getTE(tid) ?? options.getTE(), 100);

  return ret.reduce();
}

Fraction _getReactionTimeBonus(int tid, Blueprint bp, OptionsController options) {
  var ret = 1.toFraction();

  // structure
  final structure = SDE.structures[options.getSelectedReactionStructureTid()]!;
  if (structure.bonuses.containsKey(BonusType.TIME)) {
    ret *= structure.bonuses[BonusType.TIME]!.toFraction();
  }

  // rigs
  ret *= getRigBonus(tid, options.getSelectedReactionRigs().map((e) => e.tid), BonusType.TIME);

  // skill
  ret *= getSkillBonus(tid, bp, options);

  return ret.reduce();
}

Fraction getRigBonus(int tid, Iterable<int> rigs, BonusType bonusType) {
  Fraction bestRigBonus = 1.toFraction();
  for (int rigID in rigs) {
    final rig = SDE.rigs[rigID]!;
    if (rig.bonuses.containsKey(bonusType)) {
      if (rigAffectsItem(tid, rig)) {
        // Only apply the best material bonus, in the case that multiple rigs give a bonus to the same item.
        // If I supported multiple structures (each with only 3 rigs at most) then, for each item i would have to
        // choose a structure. I would choose the best structure... like how do i define that? what if one structure
        // is rigged for ME and another for TE, then what is more important ME or TE?
        // well let the user decide... now u have to design the ui to let the user decide, and also have to explain
        // it to the user so it makes sense. 'prefer to build item in structure with best [ME / TE button]'.
        // Now you have to tell the user how much of what materials go where...
        // can be done.. but damn.
        // that's a project for another month.
        // One use case would be where an alliance has two Mfg structures:
        //    one rigged for components and another rigged for ship mfg..
        // meh..
        final rigBonus = 1.toFraction() + rig.bonuses[bonusType]!.toFraction() / 100.toFraction();
        if (rigBonus < bestRigBonus) {
          bestRigBonus = rigBonus;
        }
      }
    }
  }
  return bestRigBonus.reduce();
}

bool rigAffectsItem(int tid, Rig rig) {
  int groupID = SDE.items[tid]!.groupID;
  int categoryID = SDE.group2category[groupID]!; // groupID parent
  return rig.domainGroupIDs.contains(groupID) || rig.domainCategoryIDs.contains(categoryID);
}

Fraction getSkillBonus(int tid, Blueprint bp, OptionsController options) {
  var ret = 1.toFraction();
  for (var skillData in options.getSkills()) {
    if (bp.skills.contains(skillData.tid)) {
      ret = (ret *
              (1.toFraction() +
                  skillData.level.toFraction() * SDE.skills[skillData.tid]!.bonus.toFraction() / 100.toFraction()))
          .reduce();
    }
  }
  return ret;
}

double getCostOfJobs(
    Schedule schedule, Map<int, double> adjustedPrices, double mfgCostIndex, double rtnCostIndex, double mfgCostBonus) {
  double value = 0.0;
  schedule.getBatches().forEach((indyType, batches) {
    final costIndex = (indyType == IndustryType.MANUFACTURING ? mfgCostIndex : rtnCostIndex) / 100;
    final costBonus = indyType == IndustryType.MANUFACTURING ? mfgCostBonus : 1;
    for (var batch in batches) {
      batch.items.forEach((tid, batchItem) {
        double baseCosts = 0.0;
        SD.materials(tid).forEach((cid, qtyPerRun) {
          baseCosts += qtyPerRun * (adjustedPrices[cid] ?? 0);
        });
        final numRuns = batchItem.runs;
        final numSlots = batchItem.slots;
        final runsPerLine = (numRuns / numSlots).floor();
        final numLinesWithExtraRun = numRuns % numSlots;
        final x = (numSlots - numLinesWithExtraRun) * runsPerLine * baseCosts;
        final y = numLinesWithExtraRun * (runsPerLine + 1) * baseCosts;
        value += (x + y) * costIndex * costBonus;
      });
    }
  });
  return value;
}
