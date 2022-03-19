import 'package:sqlite3/sqlite3.dart';
import 'table.dart';

class IndustryBlueprintMaxRunTable extends Table {
  @override
  IndustryBlueprintMaxRunTable(Database db) : super(db);

  @override
  String getTableName() => 'industryBlueprints';

  @override
  List<String> getColumnNames() => ['typeID', 'maxProductionLimit'];

  @override
  List<String> getTypeNames() => ['INTEGER', 'INTEGER'];

  void insert(int typeID, int maxProductionLimit) {
    db.execute(getInsertStatement([typeID, maxProductionLimit]));
  }
}
