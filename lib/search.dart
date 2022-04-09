import 'gui/widgets/test_names.dart';
import 'fuzzysort.dart';

class MyFilterSearch {
  final fuzzysort = FuzzySort(FuzzySortOptions(threshold: -1000));

  List<int> search(String query) {
    final res = fuzzysort.go(query, names.length, (int xx) => names[xx]);
    // print('--------------------------------------------------------');
    // int i = 0;
    // for (var r in res) {
    //   print(names[r.index].toString() + ' : ' + r.score.toString());
    //   i += 1;
    //   if (i >= 50) break;
    // }
    // print(res.length);
    return res.map((e) => e.index).toList();
  }
}
