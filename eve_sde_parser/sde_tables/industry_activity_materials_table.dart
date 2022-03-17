import 'package:sqlite3/sqlite3.dart';
import 'table.dart';

class IndustryActivityMaterialsTable extends Table {
  @override
  IndustryActivityMaterialsTable(Database db) : super(db);

  @override
  String getTableName() => 'industryActivityMaterials';

  @override
  List<String> getColumnNames() => ['typeID', 'materialTypeID', 'quantity'];

  @override
  List<String> getTypeNames() => ['INTEGER', 'INTEGER', 'INTEGER'];

  void insert(int typeID, int materialTypeID, int quantity) {
    db.execute(getInsertStatement([typeID, materialTypeID, quantity]));
  }
}
