import 'fuzzysort.dart';

class FilterSearch {
  final fuzzySort = FuzzySort(FuzzySortOptions(threshold: -1000));

  // Returns a subset of the list of list indices of candidates.
  List<int> search(String query, List<List<String>> candidates) {
    final res = fuzzySort.go(query, candidates.length, (int i) => candidates[i]);
    return res.map((e) => e.index).toList();
  }
}
