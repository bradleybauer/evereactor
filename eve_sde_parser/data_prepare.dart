import 'dart:io';

import 'eve_sde.dart';
import 'load_sql_lib.dart';
import 'package:sqlite3/sqlite3.dart';
import 'items_and_bps_cache.dart';

// output to lib/eve_static_data_raw.dart
void main() {
  loadSqlLib();

  final db = sqlite3.open('C:\\Users\\Bradley\\Downloads\\sqlite-latest.sqlite');
  final sde = EveSDE(db);

  String code = """import 'item.dart';
import 'blueprint.dart';
const List<int> advancedMoonGooIds_ = [""";

  final advMoonMatIDs = sde.getAdvancedMoonMaterialsTypeIDs();
  for (var id in advMoonMatIDs) {
    code += id.toString() + ',';
  }
  code += '];\n';

  final cache = ItemsAndBPsCache(advMoonMatIDs, sde);

  code += 'const List<int> fuelBlockIds_ = [';
  for (var item in cache.getItems().values) {
    if (sde.isFuelBlock(item.typeID)) {
      code += item.typeID.toString() + ',';
    }
  }
  code += '];\n';

  code += 'const Map<int, Item> items_ = {';
  for (var item in cache.getItems().values) {
    code += item.typeID.toString() +
        ':' +
        'Item(' +
        item.typeID.toString() +
        ',"' +
        item.typeName +
        '",' +
        item.volume.toString() +
        ',' +
        item.iconID.toString() +
        '),';
  }
  code += '};\n';

  code += 'const Map<int, Blueprint> blueprints_ = {';
  for (var bp in cache.getBlueprints().values) {
    code += bp.productTypeID.toString() +
        ':' +
        'Blueprint(' +
        bp.typeID.toString() +
        ',"' +
        bp.typeName +
        '",' +
        bp.productTypeID.toString() +
        ',' +
        bp.iconID.toString() +
        ',' +
        bp.numProducedPerRun.toString() +
        ',' +
        bp.inputTypeIDs.toString() +
        ',' +
        bp.inputQuantities.toString() +
        ',' +
        bp.baseTimePerRunSeconds.toString() +
        '),';
  }
  code += '};\n';

  code += 'const Map<String, int> name2id_ = {';
  for (var item in cache.getItems().values) {
    code += '"' + item.typeName + '":' + item.typeID.toString() + ',';
  }
  code += '};\n';

  RandomAccessFile file = File('lib/eve_static_data_raw.dart').openSync(mode: FileMode.writeOnly);
  file.writeStringSync(code);
  file.closeSync();

  code = """
class Constants {
  static const ADVANCED_MOON_MATERIAL_MARKET_GROUP_ID = ${sde.constants.ADVANCED_MOON_MATERIAL_MARKET_GROUP_ID};
  static const PROCESSED_MOON_MATERIAL_MARKET_GROUP_ID = ${sde.constants.PROCESSED_MOON_MATERIAL_MARKET_GROUP_ID};
  static const RAW_MOON_MATERIAL_MARKET_GROUP_ID = ${sde.constants.RAW_MOON_MATERIAL_MARKET_GROUP_ID};
  static const FUEL_BLOCK_MARKET_GROUP_ID = 1870;
  static const TEST_REACTION_BP_TYPE_ID = ${sde.constants.TEST_REACTION_BP_TYPE_ID};
  static const THE_FORGE_REGION_ID = ${sde.constants.THE_FORGE_REGION_ID};
  static const DOMAIN_REGION_ID = ${sde.constants.DOMAIN_REGION_ID};
  static const SINQ_LAISON_REGION_ID = ${sde.constants.SINQ_LAISON_REGION_ID};
  static const METROPOLIS_REGION_ID = ${sde.constants.METROPOLIS_REGION_ID};
  static const HEIMATAR_REGION_ID = ${sde.constants.HEIMATAR_REGION_ID};
  static const AMARR_SYSTEM_ID = ${sde.constants.AMARR_SYSTEM_ID};
  static const ASHAB_SYSTEM_ID = ${sde.constants.ASHAB_SYSTEM_ID};
  static const JITA_SYSTEM_ID = ${sde.constants.JITA_SYSTEM_ID};
  static const PERIMETER_SYSTEM_ID = ${sde.constants.PERIMETER_SYSTEM_ID};
  static const DODIXIE_SYSTEM_ID = ${sde.constants.DODIXIE_SYSTEM_ID};
  static const BOTANE_SYSTEM_ID = ${sde.constants.BOTANE_SYSTEM_ID};
  static const RENS_SYSTEM_ID = ${sde.constants.RENS_SYSTEM_ID};
  static const FRARN_SYSTEM_ID = ${sde.constants.FRARN_SYSTEM_ID};
  static const HEK_SYSTEM_ID = ${sde.constants.HEK_SYSTEM_ID};
}
""";

  file = File('lib/constants.dart').openSync(mode: FileMode.writeOnly);
  file.writeStringSync(code);
  file.closeSync();
}
