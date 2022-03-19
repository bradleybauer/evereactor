import 'sde_tables/map_regions.dart';
import 'sde_tables/map_solar_systems.dart';
import 'sde_tables/market_groups.dart';
import 'sde_tables/inv_types_table.dart';

class Constants {
  final MapSolarSystemsTable systemsTable;
  final MapRegionsTable regionsTable;
  final InvTypesTable typesTable;
  final InvMarketGroupsTable marketGroupsTable;

  // This class acts a bit differently when in a testing environment
  final bool isTesting;
  static const int ArbitraryIdNumber = -1000000;

  Constants(db, this.isTesting)
      : systemsTable = MapSolarSystemsTable(db),
        regionsTable = MapRegionsTable(db),
        typesTable = InvTypesTable(db),
        marketGroupsTable = InvMarketGroupsTable(db) {
    if (isTesting) {
      // There is no information about id's in testing databases
      // So just use the default values
      return;
    }

    ADVANCED_MOON_MATERIAL_MARKET_GROUP_ID = _getMarketGroupID('Advanced Moon Materials');
    PROCESSED_MOON_MATERIAL_MARKET_GROUP_ID = _getMarketGroupID('Processed Moon Materials');
    RAW_MOON_MATERIAL_MARKET_GROUP_ID = _getMarketGroupID('Raw Moon Materials');

    THE_FORGE_REGION_ID = _getRegionID('The Forge');
    DOMAIN_REGION_ID = _getRegionID('Domain');
    SINQ_LAISON_REGION_ID = _getRegionID('Sinq Laison');
    METROPOLIS_REGION_ID = _getRegionID('Metropolis');
    HEIMATAR_REGION_ID = _getRegionID('Heimatar');

    AMARR_SYSTEM_ID = _getSystemID('Amarr');
    ASHAB_SYSTEM_ID = _getSystemID('Ashab');
    JITA_SYSTEM_ID = _getSystemID('Jita');
    PERIMETER_SYSTEM_ID = _getSystemID('Perimeter');
    DODIXIE_SYSTEM_ID = _getSystemID('Dodixie');
    BOTANE_SYSTEM_ID = _getSystemID('Botane');
    RENS_SYSTEM_ID = _getSystemID('Rens');
    FRARN_SYSTEM_ID = _getSystemID('Frarn');
    HEK_SYSTEM_ID = _getSystemID('Hek');

    TEST_REACTION_BP_TYPE_ID = _getTypeID('Test Reaction Blueprint');
  }

  int _getMarketGroupID(String name) {
    name = "'" + name + "'";
    return marketGroupsTable.select(['marketGroupID'], 'marketGroupName=$name').last['marketGroupID'];
  }

  int _getRegionID(String region) {
    region = "'" + region + "'";
    return regionsTable.select(['regionID'], 'regionName=$region').last['regionID'];
  }

  int _getSystemID(String system) {
    system = "'" + system + "'";
    return systemsTable.select(['solarSystemID'], 'solarSystemName=$system').last['solarSystemID'];
  }

  int _getTypeID(String item) {
    item = "'" + item + "'";
    return typesTable.select(['typeID'], 'typeName=$item').last['typeID'];
  }

  int ADVANCED_MOON_MATERIAL_MARKET_GROUP_ID = ArbitraryIdNumber;
  int PROCESSED_MOON_MATERIAL_MARKET_GROUP_ID = ArbitraryIdNumber + 1;
  int RAW_MOON_MATERIAL_MARKET_GROUP_ID = ArbitraryIdNumber + 2;

  // I do not look this up because there are two market groups named 'Fuel Blocks'
  int FUEL_BLOCK_MARKET_GROUP_ID = 1870;

  // This item is included in some queries related to reactions so it needs to be ignored
  int TEST_REACTION_BP_TYPE_ID = ArbitraryIdNumber + 3;

  int THE_FORGE_REGION_ID = ArbitraryIdNumber + 4;
  int DOMAIN_REGION_ID = ArbitraryIdNumber + 5;
  int SINQ_LAISON_REGION_ID = ArbitraryIdNumber + 6;
  int METROPOLIS_REGION_ID = ArbitraryIdNumber + 7;
  int HEIMATAR_REGION_ID = ArbitraryIdNumber + 8;

  int AMARR_SYSTEM_ID = ArbitraryIdNumber + 9;
  int ASHAB_SYSTEM_ID = ArbitraryIdNumber + 10;
  int JITA_SYSTEM_ID = ArbitraryIdNumber + 11;
  int PERIMETER_SYSTEM_ID = ArbitraryIdNumber + 12;
  int DODIXIE_SYSTEM_ID = ArbitraryIdNumber + 13;
  int BOTANE_SYSTEM_ID = ArbitraryIdNumber + 14;
  int RENS_SYSTEM_ID = ArbitraryIdNumber + 15;
  int FRARN_SYSTEM_ID = ArbitraryIdNumber + 16;
  int HEK_SYSTEM_ID = ArbitraryIdNumber + 17;
}
