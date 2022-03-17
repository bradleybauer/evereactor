import 'package:sqlite3/sqlite3.dart';
import 'table.dart';

class InvMarketGroupsTable extends Table {
  @override
  InvMarketGroupsTable(Database db) : super(db);

  @override
  String getTableName() => 'invMarketGroups';

  @override
  List<String> getColumnNames() => ['marketGroupID', 'marketGroupName'];

  @override
  List<String> getTypeNames() => ['INTEGER', 'VARCHAR(100)'];

  void insert(int marketGroupID, String marketGroupName) {
    marketGroupName = "'" + marketGroupName + "'";
    db.execute(getInsertStatement([marketGroupID, marketGroupName]));
  }
}
