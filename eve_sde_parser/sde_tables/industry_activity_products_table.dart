import 'package:sqlite3/sqlite3.dart';
import 'table.dart';

class IndustryActivityProductsTable extends Table {
  @override
  IndustryActivityProductsTable(Database db) : super(db);

  @override
  String getTableName() => 'industryActivityProducts';

  @override
  List<String> getColumnNames() => ['typeID', 'productTypeID', 'quantity'];

  @override
  List<String> getTypeNames() => ['INTEGER', 'INTEGER', 'INTEGER'];

  void insert(int typeID, int productTypeID, int quantity) {
    db.execute(getInsertStatement([typeID, productTypeID, quantity]));
  }
}
