import 'package:flutter/material.dart';

import '../models/inventory.dart';
import '../solver/problem.dart';
import '../solver/schedule.dart';

abstract class ScheduleProvider extends ChangeNotifier {
  Problem? getProblem();
  Schedule? getSchedule();

  Map<int, int> getTid2Runs();
  Inventory getInventoryCopy();
  Set<int> getTargetsIDs();

  void computeNewBasicSchedule();

  String toCSV();
}