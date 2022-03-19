import 'package:sqlite3/sqlite3.dart';
import 'table.dart';

class MapSolarSystemsTable extends Table {
  @override
  MapSolarSystemsTable(Database db) : super(db);

  @override
  String getTableName() => 'mapSolarSystems';

  @override
  List<String> getColumnNames() => ['regionID', 'solarSystemID', 'solarSystemName'];

  @override
  List<String> getTypeNames() => ['INTEGER', 'INTEGER', 'VARCHAR(100)'];

  void insert(int regionID, int solarSystemID, String solarSystemName) {
    solarSystemName = "'" + solarSystemName + "'";
    db.execute(getInsertStatement([regionID, solarSystemID, solarSystemName]));
  }
}
