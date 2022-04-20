import 'bonus_type.dart';
import 'industry_type.dart';

class Structure {
  final IndustryType industryType;
  final Map<BonusType, double> bonuses;
  final Map<String, String> nameLocalizations;

  const Structure(
    this.industryType,
    this.bonuses,
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
