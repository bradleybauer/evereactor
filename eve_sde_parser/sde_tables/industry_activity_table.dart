import 'package:sqlite3/sqlite3.dart';
import 'table.dart';

class IndustryActivityTable extends Table {
  @override
  IndustryActivityTable(Database db) : super(db);

  @override
  String getTableName() => 'industryActivity';

  @override
  List<String> getColumnNames() => ['typeID', 'time'];

  @override
  List<String> getTypeNames() => ['INTEGER', 'INTEGER'];

  void insert(int typeID, int time) {
    db.execute(getInsertStatement([typeID, time]));
  }
}
