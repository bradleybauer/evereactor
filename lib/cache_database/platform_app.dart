import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PlatformInterface {
  static QueryExecutor createDatabaseConnection(String databaseName) {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      // for (var folder in await dbFolder.list().toList()) {
      //   if (folder.uri.pathSegments.isNotEmpty) {
      //     print(folder.uri.pathSegments);
      //   }
      // }
      final file = File(join(dbFolder.path, '$databaseName.sqlite'));
      return NativeDatabase(file);
    });
  }
}
