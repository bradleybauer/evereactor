import 'package:sqlite3/sqlite3.dart';

abstract class Table {
  String getTableName();
  List<String> getColumnNames();
  List<String> getTypeNames();
  final Database db;

  Table(this.db);

  String getCreateStatement() {
    String createStatement = 'create table ' + getTableName() + ' (';
    final names = getColumnNames();
    final types = getTypeNames();
    for (int i = 0; i < names.length - 1; ++i) {
      createStatement += names[i] + ' ' + types[i] + ', ';
    }
    if (names.isNotEmpty) {
      createStatement += names.last + ' ' + types.last;
    }
    createStatement += ')';
    return createStatement;
  }

  String getInsertStatement(List<dynamic> values) {
    final columns = getColumnNames();
    if (columns.length != values.length) {
      return '';
    }
    String statement = 'insert into ' + getTableName();
    final names = getColumnNames();
    statement += ' (' + names.join(', ') + ') values (' + values.join(', ') + ')';
    return statement;
  }

  String getSelectStatement(List<String> columns, String where) {
    var statement = 'select ' + columns.join(', ') + ' from ' + getTableName();
    if (where.isNotEmpty) {
      statement += ' where ' + where;
    }
    return statement;
  }

  void create() {
    db.execute(getCreateStatement());
  }

  ResultSet select(List<String> columns, String where) {
    return db.select(getSelectStatement(columns, where));
  }
}
