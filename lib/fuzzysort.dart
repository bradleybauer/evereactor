import 'dart:core';
import 'package:collection/collection.dart';

import 'pair.dart';

// This is a partial translation of the javascript library https://github.com/farzher/fuzzysort
// I have changed a lot though too.
// I changed the getBeginningIndexes function so that it, hopefully, works for more languages than only english.
// Highlighting is turned off for now.
// Custom scoring function is, atm, not supported.
// Async is not supported.
// I removed the data objects from the inputs.
// Basically, this just gives a permutation of the getTargets : int -> int function.

// One benefit of not putting 'all' the market groups into separate matching targets is that you could have
// 'Ships .. Minmatar' be a matching target... Wait, that really doesn't mater does it because this searching lib
// is very sensitive to incorrect spelling.... :(.

// So this will not work exactly as expected for all languages
// https://stackoverflow.com/questions/3797746/how-to-do-a-python-split-on-languages-like-chinese-that-dont-use-whitespace
// fuck it.
//
// Scoring works as follows
//   split search string into parts based on space delimeter
//     for each part string
//       score part string against targets as normal (using the max over all targets as the score for the part)
//     then score for the original search string is the sum of the scores for each part? ( plus the score for the max matching of the original string )
//
//   This way, searching
//     amarr frigates will sort all amarr frigates earlier.
//     large blaster will sort all large blasters earlier

const int infinity = 9007199254740991;
final int MaxNumSplits = 5; // TODO cannot make this too large https://github.com/farzher/fuzzysort/issues/80 ? it's just very slow.

// TODO(no priority) there are definitely improvements to be made here given that I split the input strings and given the particular
//                    scoring funciton I am using. I think each successive split can work on only the data accepted by the previous split....

class FuzzySortOptions {
  final int limit;
  final int threshold;
  // int? Function(List<FuzzyMatch>)? scoreFn;
  FuzzySortOptions({this.limit = infinity, this.threshold = -infinity});
}

class FuzzyResult {
  final int index;
  final int score;
  FuzzyResult({required this.index, required this.score});
}

class _FuzzySearchPart {
  final String lower;
  final List<int> lowerCodes;
  _FuzzySearchPart(this.lower, this.lowerCodes);
}

class FuzzyMatch {
  final int score;
  // final int targetIndex;     need this if allowing custom scoring function. otherwise which target had which score?
  // final indexes = <int>[];   need this if doing highlighting
  FuzzyMatch({this.score = 0});
}

class FuzzySort {
  FuzzySort(this.options);
  final FuzzySortOptions options;

  final matchesSimple = <int>[];
  final matchesStrict = <int>[];

  // Holds the k=options.limit number of items with best score.
  // We do this by giving the worst scoring item the highest priority in the queue.
  // Then to check if we should add an item to our set of k best items we check if it has a better score
  // than the worst in our set (check if it has a higher priority than the maximum priority item of the queue, which is fast).
  final q = PriorityQueue<FuzzyResult>((a, b) => a.score < b.score
      ? -1
      : a.score == b.score
          ? 0
          : 1);

  // Memoize search/target match score in case different items share targets. (My data has a lot of these cases)
  // Could be decided in FuzzySortOptions to use this or not.
  final Map<Pair<String, String>, FuzzyMatch> _algMemo = {};

  // Search for [search] through [numItems] number of items.
  // Each item has a set of matching targets provided by [getTargets].
  // The comparison of [search] against each target is given a score.
  // The overal score of an item is the max of the scores of all it's targets when compared with [search].
  // The items are sorted in descending order based on this score.
  List<FuzzyResult> go(final String search, final int numItems, List<String> Function(int) getTargets) {
    if (search.trim() == '') {
      return [];
    }

    final List<_FuzzySearchPart> parts = _splitSearch(search);
    int resultsLen = 0;

    // final scoreFn = options.scoreFn ?? _defaultScoreFn;
    final scoreFn = _defaultScoreFn;
    for (int i = 0; i < numItems; ++i) {
      final targets = getTargets(i);
      final matches = <List<FuzzyMatch>>[];
      for (final part in parts) {
        final splitMatches = <FuzzyMatch>[];
        for (String target in targets) {
          FuzzyMatch? result = _algorithm(part.lowerCodes, part.lower, target);
          if (result != null) {
            splitMatches.add(result);
          }
        }
        matches.add(splitMatches);
      }
      int? score = scoreFn(matches);
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
      _cleanup();
      return [];
    }
    final results = <FuzzyResult>[];
    while (q.isNotEmpty) {
      results.add(q.removeFirst());
    }
    _cleanup();
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

  FuzzyMatch? _algorithm(List<int> searchLowerCodes, final String search, final String target) {
    final memoKey = Pair<String, String>(first: search, second: target);
    if (_algMemo.containsKey(memoKey)) {
      return _algMemo[target];
    }
    int searchLowerCode = searchLowerCodes[0];
    final targetLowerCodes = target.toLowerCase().codeUnits.toList();
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
            int searchLowerCodeNew = searchLowerCodes[searchI];
            if (searchLowerCode == searchLowerCodeNew) continue; // doesn't make sense to transpose a repeat char
            typoSimpleI = searchI;
          } else {
            if (typoSimpleI == 1) return null; // reached the end of the line for transposing
            --typoSimpleI;
            searchI = typoSimpleI;
            searchLowerCode = searchLowerCodes[searchI + 1];
            int searchLowerCodeNew = searchLowerCodes[searchI];
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

    final List<int> nextBeginningIndexes = _prepareNextBeginningIndexes(target);
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
          int lastMatch = matchesStrict[--matchesStrictLen];
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

    // Tally up the score & keep track of matches for highlighting later
    List<int> matchesBest = matchesSimple;
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
    // target.indexes = List<int>.filled(matchesBestLen, -1);
    // for (var i = matchesBestLen - 1; i >= 0; --i) {
    //   target.indexes[i] = matchesBest[i];
    // }
    final match = FuzzyMatch(score: score);
    _algMemo[memoKey] = match;
    return match;
  }

  List<int> _prepareBeginningIndexes(String target) {
    List<int> beginningIndexes = <int>[];
    var beginningIndexesLen = 0;
    var wasUpper = false;
    List<int> targetLowerCodeUnits = target.toLowerCase().codeUnits.toList();
    List<int> targetCodeUnits = target.codeUnits.toList();
    for (var i = 0; i < target.length; ++i) {
      final targetCode = targetCodeUnits[i];
      final isUpper = targetCode != targetLowerCodeUnits[i];
      final isBeginning = isUpper && !wasUpper;
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
    List<int> beginningIndexes = _prepareBeginningIndexes(target);
    List<int> nextBeginningIndexes = <int>[];
    int lastIsBeginning = beginningIndexes[0];
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
    _algMemo.clear();
    q.clear();
    matchesSimple.clear();
    matchesStrict.clear();
  }

  int? _defaultScoreFn(List<List<FuzzyMatch>> matches) {
    var sum = 0;
    for (final partMatches in matches) {
      var max = -infinity;
      for (final match in partMatches) {
        if (match.score > max) {
          max = match.score;
        }
      }
      // Each part needs to match something
      if (max == -infinity) {
        return null;
      } else {
        sum += max;
      }
    }
    return sum;
  }

  List<_FuzzySearchPart> _splitSearch(String search) {
    var splitSearch = search.trim().split(' ').map((e) => e.toLowerCase()); // + [search];
    // Don't split into too many different search terms
    if (splitSearch.length > MaxNumSplits) {
      splitSearch = [splitSearch.join(' ')];
    }
    int numSmallTerms = 0;
    for (String split in splitSearch) {
      // Short search terms are VERY slow
      if (split.length < 3) {
        numSmallTerms += 1;
      }
      if (numSmallTerms > 2) {
        splitSearch = [splitSearch.join(' ')];
        break;
      }
    }
    // No need to search different search terms
    var unique = splitSearch.toSet();
    final parts = <_FuzzySearchPart>[];
    for (String split in unique) {
      split = split.trim();
      if (split == '') {
        continue;
      }
      parts.add(_FuzzySearchPart(split, split.codeUnits.toList()));
    }
    return parts;
  }
}
