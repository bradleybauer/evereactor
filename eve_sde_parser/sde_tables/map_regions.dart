import 'package:sqlite3/sqlite3.dart';
import 'table.dart';

class MapRegionsTable extends Table {
  @override
  MapRegionsTable(Database db) : super(db);

  @override
  String getTableName() => 'mapRegions';

  @override
  List<String> getColumnNames() => ['regionID', 'regionName'];

  @override
  List<String> getTypeNames() => ['INTEGER', 'VARCHAR(100)'];

  void insert(int regionID, String regionName) {
    regionName = "'" + regionName + "'";
    db.execute(getInsertStatement([regionID, regionName]));
  }
}
