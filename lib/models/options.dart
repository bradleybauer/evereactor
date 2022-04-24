import 'rig.dart';
import 'structure.dart';

class Options {
  int reactionSlots = 0;
  int manufacturingSlots = 0;
  int ME = 0;
  int TE = 0;
  int maxNumBps = 0;
  double reactionsSystemCostIndex = 0;
  double manufacturingSystemCostIndex = 0;
  double salesTax = 0;
  Structure? manufacturingStructure;
  Structure? reactionsStructure;

  final Map<int, int> skill2level = {};
  final List<Rig> manufacturingRigs = [];
  final List<Rig> reactionRigs = [];
  final Set<int> systems = {};
}
