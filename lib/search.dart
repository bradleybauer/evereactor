// import 'package:fuzzy/fuzzy.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import 'gui/widgets/test_names.dart';

class MyFilterSearch {
  // final fuse = Fuzzy(
  //   names,
  //   options: FuzzyOptions(
  //     findAllMatches: true,
  //     tokenize: true,
  //     threshold: 0.5,
  //   ),
  // );
  void search(String query) {
    // final result = fuse.search(query);
    // dynamic res;
    // double score = 1;
    // for (var r in result) {
    //   if (r.score < score) {
    //     score = r.score;
    //     res = r.item;
    //   }
    // }
    // print(res.toString() + ' ' + score.toString());

    print(extractTop(
      query: query,
      choices: names,
      cutoff: 50,
      limit: 4,
    ));
  }
}
