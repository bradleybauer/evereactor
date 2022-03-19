import 'package:sqlite3/sqlite3.dart';
import 'table.dart';

class InvTypesTable extends Table {
  @override
  InvTypesTable(Database db) : super(db);

  @override
  String getTableName() => 'invTypes';

  @override
  List<String> getColumnNames() => ['typeID', 'typeName', 'volume', 'marketGroupID', 'iconID'];

  @override
  List<String> getTypeNames() => ['INTEGER', 'VARCHAR(100)', 'FLOAT', 'INTEGER', 'INTEGER'];

  void insert(int typeID, String typeName, double volume, int marketGroupID, int iconID) {
    typeName = "'" + typeName + "'";
    db.execute(getInsertStatement([typeID, typeName, volume, marketGroupID, iconID]));
  }
}
