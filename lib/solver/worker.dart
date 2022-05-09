import 'dart:ffi';
import 'dart:io' show Directory;
import 'dart:isolate';

import 'package:path/path.dart' as path;

import 'ffi_conversions.dart';
import 'ffi_types.dart';
import 'problem.dart';

NativeLibrary _library = NativeLibrary(DynamicLibrary.open(path.join(Directory.current.path, 'advanced_solver_cpp/x64/Release/WINDOWSISCOOL.dll')));

// c++ message thread will call into dart and use sendPort to send a msg to the ui isolate
SendPort? _sendPort;

class WorkerArg {
  final Problem p;
  final SendPort sp;

  const WorkerArg(this.p, this.sp);
}

void startWorker(WorkerArg arg) {
  print('startWorker called');
  Pointer<FfiProblem> ffiProblem = make_problem(arg.p);
  print('made ffiProblem');
  _sendPort = arg.sp;

  // create function pointers using pointer.fromFunc to pass to cpp
  final publishSolutionPtr = Pointer.fromFunction<_PublishSolutionNativeType>(_publishSolution);
  final notifyStoppedPtr = Pointer.fromFunction<_NotifyStoppedNativeType>(_notifyStopped);

  // enter cpp message loop
  _library.startWorker(publishSolutionPtr, notifyStoppedPtr, ffiProblem.ref);

  // when cpp returns control flow we just exit
  destroy_problem(ffiProblem);

  print('exiting startWorker');
  Isolate.exit();
}

void stopWorker() => _library.stopWorker();

typedef _PublishSolutionNativeType = Void Function(FfiSchedule schedule);
void _publishSolution(FfiSchedule schedule) {
  _sendPort?.send('hai from cpp');
}

typedef _NotifyStoppedNativeType = Void Function();
void _notifyStopped() {
  _sendPort?.send('please stop!');
}