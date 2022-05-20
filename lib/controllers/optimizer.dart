import 'package:flutter/foundation.dart';

import 'schedule_provider_desktop.dart';

class OptimizerController with ChangeNotifier {
  final ScheduleProviderDesktop _scheduleProvider;

  OptimizerController(this._scheduleProvider) {
    _scheduleProvider.addListener(_onNewSchedule);
  }

  void _onNewSchedule() {
    notifyListeners();
  }

  double getTimeBonus() {
    return _scheduleProvider.getTimeBonus();
  }

  bool isOptimal() {
    return _scheduleProvider.isOptimal();
  }

  void setExposeBasic() {
    _scheduleProvider.setExposeAdvSchedule(false);
  }

  void setExposeAdv() {
    _scheduleProvider.setExposeAdvSchedule(true);
  }

  void startOptimizer() async {
    _scheduleProvider.startAdvancedSolver();
  }

  void stopOptimizer() async {
    _scheduleProvider.stopAdvancedSolver();
  }

  bool isBasicExposed() => !_scheduleProvider.exposingAdvancedSchedule;
}
