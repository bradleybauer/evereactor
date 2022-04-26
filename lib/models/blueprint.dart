import 'industry_type.dart';

class Blueprint {
  final IndustryType industryType;
  final int numProducedPerRun;
  final Map<int, int> input2quantity;
  final int timePerRun;
  final List<int> skills;
  final int? techLevel;

  const Blueprint(this.industryType,
      this.numProducedPerRun,
      this.input2quantity,
      this.timePerRun,
      this.skills,
      [this.techLevel]);
}
