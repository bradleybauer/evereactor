import 'gui/widgets/test_names.dart';
import 'fuzzysort.dart';

class MyFilterSearch {
  void search(String query) {
    var options = FuzzySortOptions();
    // options.threshold = -200;
    options.threshold = -1000;
    // options.limit = 50;
    var fuzzysort = FuzzySort(options);

    var res = fuzzysort.go(query, names.length, (int xx) => names[xx]);
    print('--------------------------------------------------------');
    int i = 0;
    for (var r in res) {
      print(names[r.index].toString() + ' : ' + r.score.toString());
      i += 1;
      if (i >= 5) break;
    }
    print(res.length);
  }
}
