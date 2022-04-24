import 'rig.dart';
import 'structure.dart';

class Options {
  final Map<int, int> skill2level;
  final int reactionSlots;
  final int manufacturingSlots;
  final int ME;
  final int TE;
  final int maxNumBps;
  final double reactionsSystemCostIndex;
  final double manufacturingSystemCostIndex;
  final double salesTax;
  final Structure manufacturingStructure;
  final Structure reactionsStructure;
  final List<Rig> manufacturingRigs;
  final List<Rig> reactionRigs;
  final Set<int> systems;

  Options(
    this.skill2level,
    this.reactionSlots,
    this.manufacturingSlots,
    this.ME,
    this.TE,
    this.maxNumBps,
    this.reactionsSystemCostIndex,
    this.manufacturingSystemCostIndex,
    this.salesTax,
    this.reactionsStructure,
    this.manufacturingStructure,
    this.reactionRigs,
    this.manufacturingRigs,
    this.systems,
  );
}
