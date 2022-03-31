class EveBuildContext {
  final int reactionSkillLevel;
  final double structureMaterialBonus;
  final double structureTimeBonus;
  // TODO bb note: system cost is like a percent, if the cost index is 3 then this should be interpreted as 3/100.
  final double systemCostIndex;
  final double salesTaxPercent;
  final double brokersFeePercent;
  EveBuildContext(this.reactionSkillLevel, this.structureMaterialBonus, this.structureTimeBonus, this.systemCostIndex, this.salesTaxPercent,
      this.brokersFeePercent);
}
