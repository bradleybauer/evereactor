import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

void loadSqlLib() {
  open.overrideFor(OperatingSystem.windows, _libOpenOnWindows);
}

DynamicLibrary _libOpenOnWindows() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final libraryNextToScript = File('${scriptDir.path}/sqlite3.dll');
  return DynamicLibrary.open(libraryNextToScript.path);
}
