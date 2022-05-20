import '../solver/advanced_solver.dart';
import '../solver/schedule.dart';
import 'schedule_provider_web.dart';

class ScheduleProviderDesktop extends ScheduleProviderWeb {
  final AdvancedSolver _advancedSolver = AdvancedSolver();

  ScheduleProviderDesktop({required super.inventory, required super.options, required super.buildItems}) {
    _advancedSolver.addListener(_advancedSolverFoundNewSolution);
  }

  Schedule? _advSchedule;
  bool exposingAdvancedSchedule = false;

  @override
  void handleBuildChanged() {
    stopAdvancedSolver();
    _advSchedule = null;
    exposingAdvancedSchedule = false;
    super.handleBuildChanged();
  }

  void setExposeAdvSchedule(bool x) {
    exposingAdvancedSchedule = x;
    notifyListeners();
  }

  @override
  Schedule? getSchedule() {
    if (exposingAdvancedSchedule && _advSchedule != null) {
      return _advSchedule;
    } else {
      return super.getSchedule();
    }
  }

  void startAdvancedSolver() {
    super.computeNewBasicSchedule();
    super.getProblem()!.approximation = super.getSchedule();
    _advancedSolver.solve(super.getProblem()!);
  }

  void _advancedSolverFoundNewSolution() {
    _advSchedule = _advancedSolver.getSchedule();
    notifyListeners();
  }

  void stopAdvancedSolver() async {
    _advancedSolver.stop();
  }

  double getTimeBonus() => _advSchedule != null ? (1.0 - _advSchedule!.time / super.getSchedule()!.time) : double.negativeInfinity;

  bool isOptimal() => _advSchedule != null ? _advSchedule!.isOptimal : false;
}
