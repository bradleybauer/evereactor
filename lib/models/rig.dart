import 'bonus_type.dart';
import 'industry_type.dart';

class Rig {
  final IndustryType industryType;
  final Map<BonusType, double> bonuses;
  final Set<int> domainCategoryIDs;
  final Set<int> domainGroupIDs;
  final Map<String, String> nameLocalizations;

  const Rig(
    this.industryType,
    this.bonuses,
    this.domainCategoryIDs,
    this.domainGroupIDs,
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
