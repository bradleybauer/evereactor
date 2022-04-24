import '../sde.dart';
import 'rig.dart';
import 'structure.dart';

class Options {
  int _reactionSlots = 60;
  int _manufacturingSlots = 60;
  int _ME = 0;
  int _TE = 0;
  int _maxNumBps = 999;
  double _reactionsSystemCostIndex = .1;
  double _manufacturingSystemCostIndex = .1;
  double _salesTax = 0;
  Structure? _manufacturingStructure;
  Structure? _reactionsStructure;

  final Map<int, int> _skill2level = {};
  final List<Rig> _manufacturingRigs = [];
  final List<Rig> _reactionRigs = [];
  final Set<int> _systems = {};

  void setAllSkillLevels(int level) => SDE.skills.keys.forEach((int tid) => _skill2level[tid] = level);

  void setSkillLevel(int tid, int level) => _skill2level[tid] = level;

  int getSkillLevel(int tid) {
    if (!_skill2level.containsKey(tid)) {
      _skill2level[tid] = 4;
    }
    return _skill2level[tid]!;
  }

  int getReactionSlots() => _reactionSlots;

  void setReactionSlots(int slots) => _reactionSlots = slots;

  int getManufacturingSlots() => _manufacturingSlots;

  void setManufacturingSlots(int slots) => _manufacturingSlots = slots;

  int getME() => _ME;

  void setME(int ME) => _ME = ME;

  int getTE() => _TE;

  void setTE(int TE) => _TE = TE;

  int getMaxNumBlueprints() => _maxNumBps;

  void setMaxNumBlueprints(int maxBps) => _maxNumBps = maxBps;

  double getReactionSystemCostIndex() => _reactionsSystemCostIndex;

  void setReactionSystemCostIndex(double index) => _reactionsSystemCostIndex = index;

  double getManufacturingSystemCostIndex() => _manufacturingSystemCostIndex;

  void setManufacturingSystemCostIndex(double index) => _manufacturingSystemCostIndex = index;

  double getSalesTax() => _salesTax;

  void setSalesTax(double tax) => _salesTax = tax;
}
