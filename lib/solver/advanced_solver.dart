import 'dart:isolate';

import 'package:flutter/foundation.dart';

import 'worker.dart';
import 'problem.dart';
import 'schedule.dart';

/*
(ui isolate)     (msgr isolate)            (solver thread)
request start -> enters c++ event loop
                 starts                 -> stars solving
                 sleeps
                 ...
                 wakes                  <- solver thread provides schedule
                 returns to dart
                 gets sch (2c++)
updates ui    <- msgs ui of new sch
                 enters c++ event loop
                 sleeps
                 ...
                 wakes                  <- solver thread provides schedule
                 returns to dart
                 gets sch (2c++)
updates ui    <- msgs ui of new sch
                 enters c++ event loop
                 sleeps
                 ...
--------------------------------------------------------------------------------------
request stop  -> wakes
(2c++)           stops solver thread
                 returns to dart
                 Isolate.exit()
--------------------------------------------------------------------------------------
or
--------------------------------------------------------------------------------------
                 wakes                  <- solver finishes optimization
                 stops solver thread
                 returns to dart
                 Isolate.exit()
--------------------------------------------------------------------------------------
*/

class AdvancedSolver extends ChangeNotifier {
  Isolate? _currentWorker;

  // A port for listening for messages from the worker isolate
  final ReceivePort rp = ReceivePort();

  AdvancedSolver() {
    rp.listen(_handleReceiveMessage);
  }

  void _handleReceiveMessage(msg) {
    print(msg);
    notifyListeners();
  }

  void solve(Problem prob) async {
    print('solve in adv solver called');
    stop();
    _problem = prob;
    _currentWorker = await Isolate.spawn(startWorker, WorkerArg(prob, rp.sendPort));
  }

  void stop() async {
    if (_currentWorker != null) {
      stopWorker();
    }
    _currentWorker = null;
  }

  bool get isRunning => _currentWorker != null;

  Problem? _problem;
  Schedule? _schedule;

  Problem? getProblemSolved() => _problem;

  Schedule? getSchedule() => _schedule;
}

// AdvancedSolver implements ScheduleProvider -- desktop only
//   ExposeAdvancedSchedule
//      (set basic schedule as current if there is no adv schedule, then continue publishing adv schedules as discovered)
//      or
//      (set adv schedules as current as they are discovered if there is an adv schedule)
//      and notify
//
//   ExposeBasicSchedule
//      set basic schedule as current and notify
//
//   isRunning - is there an isolate doing a computation atm?
//
//   start
//   stop
