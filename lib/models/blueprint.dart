import 'industry_type.dart';

class Blueprint {
  final IndustryType industryType;
  final int numProducedPerRun;
  final Map<int, int> input2quantity;
  final int timePerRun;
  final List<int> skills;

  const Blueprint(
    this.industryType,
    this.numProducedPerRun,
    this.input2quantity,
    this.timePerRun,
    this.skills,
  );

  @override
  String toString() {
    return {
      'industryType': industryType,
      'quantity': numProducedPerRun,
      'input2quantity': input2quantity,
      'timePerRun': timePerRun,
      'skills': skills,
    }.toString();
  }
}
