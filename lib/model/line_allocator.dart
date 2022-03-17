import 'package:tuple/tuple.dart';

class LineAllocator {
  // jobs is a list of <runs, basetime> pairs
  List<Tuple2<int, int>> allocateLines(final int numLines, final List<Tuple3<int, int, int>> jobs, getTime, [bool showStats = false]) {
    final int numJobs = jobs.length;
    if (numLines < numJobs || jobs.isEmpty) {
      return [];
    }
    // var answer = _getLinesPerJob(jobs, numLines, getTime, showStats);
    List<Tuple2<int, int>> solution = [];
    // for (int i = 0; i < numJobs; i++) {
    //   solution.add(Tuple2(answer[i], jobs[i].item3));
    // }
    return solution;
  }
}
