import 'dart:core';
import 'package:collection/collection.dart';

// This is a partial translation of the javascript library https://github.com/farzher/fuzzysort
// I have change a lot though too. I changed the getBeginningIndexes function so that it, hopefully,
// works for more languages than only english.
// highlighting is turned off for now.
// I deleted a bunch of async stuff.
// I removed the data objects from the inputs.
// Basically this just gives a permutation of the getTargets(int) function.

const int infinity = 9007199254740991;

class FuzzySortOptions {
  int limit = infinity;
  int threshold = -infinity;
  // int? Function(List<FuzzyTarget>)? scoreFn;
}

class FuzzyResult {
  int index = 0;
  int score = 0;
  FuzzyResult({required this.index, required this.score});
}

class FuzzyTarget {
  String target = "";
  int targetIndex = 0;
  int score = 0;
  // List<int> indexes = [];
  List<int> lowerCodes = [];
  List<int> nextBeginningIndexes = [];
  FuzzyTarget(
      {required this.target,
      required this.targetIndex,
      this.score = 0,
      // required this.indexes,
      this.lowerCodes = const <int>[],
      this.nextBeginningIndexes = const <int>[]});
}

class FuzzySort {
  final matchesSimple = <int>[];
  final matchesStrict = <int>[];

  final q = PriorityQueue<FuzzyResult>((a, b) => a.score < b.score
      ? -1
      : a.score > b.score
          ? 1
          : 0);

  FuzzySortOptions options;
  FuzzySort(this.options);

  final Map<String, FuzzyTarget> _algMemo = {};

  List<FuzzyResult> go(final String search, final int numItems, List<String> Function(int) getTargets) {
    if (search == '') {
      return [];
    }
    final searchLowerCodes = search.toLowerCase().codeUnits.toList();
    int resultsLen = 0;

    // final scoreFn = options.scoreFn ?? _defaultScoreFn;
    final scoreFn = _defaultScoreFn;
    for (var i = numItems - 1; i >= 0; --i) {
      final targets = getTargets(i);
      final objResults = <FuzzyTarget>[];
      for (var ti = targets.length - 1; ti >= 0; --ti) {
        FuzzyTarget? result = _algorithm(searchLowerCodes, _getSearchData(targets[ti], ti));
        if (result != null) {
          objResults.add(result);
        }
      }
      int? score = scoreFn(objResults);
      if (score == null) continue;
      if (score < options.threshold) continue;
      final result = FuzzyResult(index: i, score: score);
      if (resultsLen < options.limit) {
        q.add(result);
        ++resultsLen;
      } else {
        if (resultsLen < options.limit) {
          q.add(result);
          ++resultsLen;
        } else if (result.score > q.first.score) {
          q.removeFirst();
          q.add(result);
        }
      }
    }

    if (resultsLen == 0) {
      return [];
    }
    final results = <FuzzyResult>[];
    while (q.isNotEmpty) {
      results.add(q.removeFirst());
    }
    return results.reversed.toList();
  }

  /*
  highlight(result, hOpen, hClose) {
    if (result == null) return null;
    hOpen ??= '<b>';
    hClose ??= '</b>';
    var highlighted = '';
    int matchesIndex = 0;
    bool opened = false;
    var target = result.target;
    int targetLen = target.length;
    var matchesBest = result.indexes;
    for (var i = 0; i < targetLen; ++i) {
      var char = target[i];
      if (matchesBest[matchesIndex] == i) {
        ++matchesIndex;
        if (!opened) {
          opened = true;
          highlighted += hOpen;
        }

        if (matchesIndex == matchesBest.length) {
          highlighted += char + hClose + target.substr(i + 1);
          break;
        }
      } else {
        if (opened) {
          opened = false;
          highlighted += hClose;
        }
      }
      highlighted += char;
    }

    return highlighted;
  }
  */

  FuzzyTarget _getSearchData(String target, int targetIndex) {
    return FuzzyTarget(
      target: target,
      targetIndex: targetIndex,
      lowerCodes: target.toLowerCase().codeUnits.toList(),
      score: -infinity,
      nextBeginningIndexes: [],
    );
  }

  FuzzyTarget? _algorithm(List<int> searchLowerCodes, FuzzyTarget target) {
    if (_algMemo.containsKey(target.target)) {
      return _algMemo[target.target];
    }
    int searchLowerCode = searchLowerCodes[0];
    final targetLowerCodes = target.lowerCodes;
    int searchLen = searchLowerCodes.length;
    int targetLen = targetLowerCodes.length;
    int searchI = 0; // where we at
    int targetI = 0; // where you at
    int typoSimpleI = 0;
    int matchesSimpleLen = 0;

    // very basic fuzzy match; to remove non-matching targets ASAP!
    // walk through target. find sequential matches.
    // if all chars aren't found then exit
    for (;;) {
      final isMatch = searchLowerCode == targetLowerCodes[targetI];
      if (isMatch) {
        if (matchesSimpleLen == matchesSimple.length) {
          matchesSimple.add(0);
        }
        matchesSimple[matchesSimpleLen++] = targetI;
        ++searchI;
        if (searchI == searchLen) break;
        searchLowerCode = searchLowerCodes[
            typoSimpleI == 0 ? searchI : (typoSimpleI == searchI ? searchI + 1 : (typoSimpleI == searchI - 1 ? searchI - 1 : searchI))];
      }

      ++targetI;
      if (targetI >= targetLen) {
        // Failed to find searchI
        // Check for typo or exit
        // we go as far as possible before trying to transpose
        // then we transpose backwards until we reach the beginning
        for (;;) {
          if (searchI <= 1) return null; // not allowed to transpose first char
          if (typoSimpleI == 0) {
            // we haven't tried to transpose yet
            --searchI;
            var searchLowerCodeNew = searchLowerCodes[searchI];
            if (searchLowerCode == searchLowerCodeNew) continue; // doesn't make sense to transpose a repeat char
            typoSimpleI = searchI;
          } else {
            if (typoSimpleI == 1) return null; // reached the end of the line for transposing
            --typoSimpleI;
            searchI = typoSimpleI;
            searchLowerCode = searchLowerCodes[searchI + 1];
            var searchLowerCodeNew = searchLowerCodes[searchI];
            if (searchLowerCode == searchLowerCodeNew) continue; // doesn't make sense to transpose a repeat char
          }
          matchesSimpleLen = searchI;
          targetI = matchesSimple[matchesSimpleLen - 1] + 1;
          break;
        }
      }
    }

    searchI = 0;
    int typoStrictI = 0;
    bool successStrict = false;
    int matchesStrictLen = 0;

    if (target.nextBeginningIndexes.isEmpty) {
      target.nextBeginningIndexes = _prepareNextBeginningIndexes(target.target);
    }
    var nextBeginningIndexes = target.nextBeginningIndexes;
    int firstPossibleI = targetI = matchesSimple[0] == 0 ? 0 : nextBeginningIndexes[matchesSimple[0] - 1];

    // Our target string successfully matched all characters in sequence!
    // Let's try a more advanced and strict test to improve the score
    // only count it as a match if it's consecutive or a beginning character!
    if (targetI != targetLen) {
      for (;;) {
        if (targetI >= targetLen) {
          // We failed to find a good spot for this search char, go back to the previous search char and force it forward
          if (searchI <= 0) {
            // We failed to push chars forward for a better match
            // transpose, starting from the beginning
            ++typoStrictI;
            if (typoStrictI > searchLen - 2) break;
            if (searchLowerCodes[typoStrictI] == searchLowerCodes[typoStrictI + 1]) continue; // doesn't make sense to transpose a repeat char
            targetI = firstPossibleI;
            continue;
          }

          --searchI;
          var lastMatch = matchesStrict[--matchesStrictLen];
          targetI = nextBeginningIndexes[lastMatch];
        } else {
          var isMatch = targetLowerCodes[targetI] ==
              searchLowerCodes[
                  typoStrictI == 0 ? searchI : (typoStrictI == searchI ? searchI + 1 : (typoStrictI == searchI - 1 ? searchI - 1 : searchI))];
          if (isMatch) {
            if (matchesStrictLen == matchesStrict.length) {
              matchesStrict.add(0);
            }
            matchesStrict[matchesStrictLen++] = targetI;
            ++searchI;
            if (searchI == searchLen) {
              successStrict = true;
              break;
            }
            ++targetI;
          } else {
            targetI = nextBeginningIndexes[targetI];
          }
        }
      }
    }

    {
      // tally up the score & keep track of matches for highlighting later

      var matchesBest = matchesSimple;
      // var matchesBestLen = matchesSimpleLen;
      if (successStrict) {
        matchesBest = matchesStrict;
        // matchesBestLen = matchesStrictLen;
      }

      var score = 0;
      var lastTargetI = -1;
      for (var i = 0; i < searchLen; ++i) {
        int targetI = matchesBest[i];
        // score only goes down if they're not consecutive
        if (lastTargetI != targetI - 1) score -= targetI;
        lastTargetI = targetI;
      }
      if (!successStrict) {
        score *= 1000;
        if (typoSimpleI != 0) score += -20; //typoPenalty
      } else {
        if (typoStrictI != 0) score += -20; //typoPenalty
      }
      score -= targetLen - searchLen;
      target.score = score;
      // target.indexes = List<int>.filled(matchesBestLen, -1);
      // for (var i = matchesBestLen - 1; i >= 0; --i) {
      //   target.indexes[i] = matchesBest[i];
      // }

      _algMemo[target.target] = target;
      return target;
    }
  }

  List<int> _prepareBeginningIndexes(String target) {
    var beginningIndexes = <int>[];
    var beginningIndexesLen = 0;
    var wasUpper = false;
    var targetLowerCodeUnits = target.toLowerCase().codeUnits.toList();
    var targetCodeUnits = target.codeUnits.toList();
    for (var i = 0; i < target.length; ++i) {
      var targetCode = targetCodeUnits[i];
      var isUpper = targetCode != targetLowerCodeUnits[i];
      var isBeginning = isUpper && !wasUpper;
      wasUpper = isUpper;
      if (isBeginning) {
        if (beginningIndexesLen == beginningIndexes.length) {
          beginningIndexes.add(0);
        }
        beginningIndexes[beginningIndexesLen++] = i;
      }
    }
    return beginningIndexes;
  }

  List<int> _prepareNextBeginningIndexes(String target) {
    var beginningIndexes = _prepareBeginningIndexes(target);
    var nextBeginningIndexes = <int>[];
    var lastIsBeginning = beginningIndexes[0];
    var lastIsBeginningI = 0;
    for (var i = 0; i < target.length; ++i) {
      if (lastIsBeginning > i) {
        if (i >= nextBeginningIndexes.length) {
          nextBeginningIndexes.add(-1);
        }
        nextBeginningIndexes[i] = lastIsBeginning;
      } else {
        ++lastIsBeginningI;
        if (lastIsBeginningI < beginningIndexes.length) {
          lastIsBeginning = beginningIndexes[lastIsBeginningI];
          if (i >= nextBeginningIndexes.length) {
            nextBeginningIndexes.add(-1);
          }
          nextBeginningIndexes[i] = lastIsBeginning;
        } else {
          if (i >= nextBeginningIndexes.length) {
            nextBeginningIndexes.add(-1);
          }
          nextBeginningIndexes[i] = target.length;
        }
      }
    }
    return nextBeginningIndexes;
  }

  void _cleanup() {
    matchesSimple.clear();
    matchesStrict.clear();
  }

  int? _defaultScoreFn(List<FuzzyTarget> a) {
    var max = -infinity;
    for (var i = a.length - 1; i >= 0; --i) {
      var result = a[i];
      var score = result.score;
      if (score > max) max = score;
    }
    if (max == -infinity) return null;
    return max;
  }
}

// import '../lib/gui/widgets/test_names.dart';
// void main() {
//   print('start');
//   var options = FuzzySortOptions();
//   options.threshold = -250;
//   // options.limit = 50;
//   var fuzzysort = FuzzySort(options);
//   var res = fuzzysort.go('reaction', names);
//   for (var r in res) {
//     print(r.target + ' : ' + r.score.toString());
//   }
// }
