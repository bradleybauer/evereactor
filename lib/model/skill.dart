import 'industry_type.dart';

class Skill {
  final IndustryType industryType;
  final int marketGroupID;
  final double bonus;
  final Map<String, String> nameLocalizations;

  const Skill(
    this.industryType,
    this.marketGroupID,
    this.bonus,
    this.nameLocalizations,
  );

  //@override
  //String toString() {
  //  return {
  //    'typeID': typeID,
  //    'typeName': typeName,
  //    'productTypeID': productTypeID,
  //    'iconID': iconID,
  //    'quantity': numProducedPerRun,
  //    'inputTypeIDs': inputTypeIDs,
  //    'inputQuantities': inputQuantities,
  //    'baseTimePerRunSeconds': baseTimePerRunSeconds
  //  }.toString();
  //}
}
