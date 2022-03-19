import 'sde_tables/industry_blueprints_table.dart';
import 'sde_tables/map_regions.dart';
import 'sde_tables/map_solar_systems.dart';
import 'sde_tables/market_groups.dart';
import 'sde_tables/industry_activity_materials_table.dart';
import 'sde_tables/industry_activity_products_table.dart';
import 'sde_tables/industry_activity_table.dart';
import 'sde_tables/inv_types_table.dart';

import 'package:sqlite3/sqlite3.dart';

import 'constants.dart';

class EveSDE {
  final Database db;

  final InvTypesTable types;
  final IndustryActivityProductsTable bpProduct;
  final IndustryActivityMaterialsTable bpMaterials;
  final IndustryActivityTable bpTime;
  final IndustryBlueprintMaxRunTable bpMaxRuns;
  final MapSolarSystemsTable systems;
  final MapRegionsTable regions;
  final InvMarketGroupsTable marketGroups;
  final bool isTesting;

  final Constants constants;

  EveSDE(this.db, {this.isTesting = false})
      : types = InvTypesTable(db),
        bpProduct = IndustryActivityProductsTable(db),
        bpMaterials = IndustryActivityMaterialsTable(db),
        bpTime = IndustryActivityTable(db),
        bpMaxRuns = IndustryBlueprintMaxRunTable(db),
        systems = MapSolarSystemsTable(db),
        regions = MapRegionsTable(db),
        marketGroups = InvMarketGroupsTable(db),
        constants = Constants(db, isTesting) {
    if (isTesting) {
      _setupForTesting();
    }
  }

  void _setupForTesting() {
    types.create();
    bpProduct.create();
    bpMaterials.create();
    bpTime.create();
  }

  void dispose() {
    db.dispose();
  }

  bool isBuildable(int typeID) {
    return bpProduct.select(['*'], 'productTypeID=$typeID').isNotEmpty;
  }

  bool isFuelBlock(int typeID) {
    return types.select(['marketGroupID'], 'typeID=$typeID').last['marketGroupID'] == constants.FUEL_BLOCK_MARKET_GROUP_ID;
  }

  List<int> getAdvancedMoonMaterialsTypeIDs() {
    final query = types.select(['typeID'], 'marketGroupID=${constants.ADVANCED_MOON_MATERIAL_MARKET_GROUP_ID}');
    return query.map((e) => e['typeID'] as int).toList();
  }
}
