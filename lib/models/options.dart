import 'industry_type.dart';
import '../sde.dart';

class Options {
  int _reactionSlots = 60;
  int _manufacturingSlots = 60;
  int _ME = 10;
  int _TE = 20;
  int _maxNumBps = 30;
  double _reactionsSystemCostIndex = .1;
  double _manufacturingSystemCostIndex = .1;
  double _salesTaxPercent = 0;
  int _manufacturingStructure =
      SDE.structures.entries.where((e) => e.value.industryType == IndustryType.MANUFACTURING).first.key;
  int _reactionStructure =
      SDE.structures.entries.where((e) => e.value.industryType == IndustryType.REACTION).first.key;

  final Map<int, int> _skill2level = {};
  final List<int> _manufacturingRigs = [];
  final List<int> _reactionRigs = [];
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

  double getSalesTaxPercent() => _salesTaxPercent;

  void setSalesTax(double tax) => _salesTaxPercent = tax;

  int getManufacturingStructure() => _manufacturingStructure;

  void setManufacturingStructure(int tid) => _manufacturingStructure = tid;

  int getReactionStructure() => _reactionStructure;

  void setReactionStructure(int tid) => _reactionStructure = tid;

  List<int> getManufacturingRigs() => _manufacturingRigs;

  void addManufacturingRig(int tid) => _manufacturingRigs.add(tid);

  void removeManufacturingRig(int i) => _manufacturingRigs.removeAt(i);

  List<int> getReactionRigs() => _reactionRigs;

  void addReactionRig(int tid) => _reactionRigs.add(tid);

  void removeReactionRig(int i) => _reactionRigs.removeAt(i);

  int getNumSelectedManufacturingRigs() => _manufacturingRigs.length;
  int getNumSelectedReactionRigs() => _reactionRigs.length;

}
