import 'dart:ffi';
import 'dart:io' show Directory;
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'ffi_conversions.dart';
import 'ffi_types.dart';
import 'problem.dart';

//NativeLibrary _library = NativeLibrary(DynamicLibrary.open(path.join(Directory.current.path, 'advanced_solver_cpp/x64/Release/WINDOWSISCOOL.dll')));
NativeLibrary _library = NativeLibrary(DynamicLibrary.open(
    path.join(Directory.current.path, kDebugMode ? 'advanced_solver_cpp/x64/Release/WINDOWSISCOOL.dll' : 'solver.dll')));

// c++ message thread will call into dart and use sendPort to send a msg to the ui isolate
SendPort? _sendPort;

class WorkerArg {
  final Problem p;
  final SendPort sp;

  const WorkerArg(this.p, this.sp);
}

void startWorker(WorkerArg arg) async {
  Pointer<FfiProblem> ffiProblem = make_problem(arg.p);
  _sendPort = arg.sp;

  // create function pointers using pointer.fromFunc to pass to cpp
  // Reminder: ptrs from Pointer.fromFunction can only be used from the thread that Pointer.fromFunction was called on.
  //           Thus this isolate.
  final publishSolutionPtr = Pointer.fromFunction<_PublishSolutionNativeType>(_publishSolution);
  final notifyStoppedPtr = Pointer.fromFunction<_NotifyStoppedNativeType>(_notifyStopped);

  // enter cpp message loop
  _library.startWorker(publishSolutionPtr, notifyStoppedPtr, ffiProblem.ref);

  // when cpp returns control flow we just exit
  destroy_problem(ffiProblem);

  print('exiting isolate');
  Isolate.exit();
}

void stopWorker() => _library.stopWorker();

typedef _PublishSolutionNativeType = Void Function(Pointer<FfiSchedule> schedule);

void _publishSolution(Pointer<FfiSchedule> schedule) {
  // notify adv solver we have a new solution
  final dartSchedule = ffi2dart_schedule(schedule.ref);

  // take ownership of the given schedule
  destroy_schedule(schedule);

  _sendPort?.send(dartSchedule);
}

typedef _NotifyStoppedNativeType = Void Function();

// Allows cpp to notify ui that is has stopped
void _notifyStopped() {
  print('notifyStopped');
  _sendPort?.send(null);
}
