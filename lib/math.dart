import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:fraction/fraction.dart';

int ceilDiv(int x, int y) {
  return (x + y - 1) ~/ y;
}

double dot(Map<int, double> x, Map<int, double> y) {
  return x.entries.fold(0.0, (double p, e) => p + (y[e.key]??0) * e.value);
}

Map<int,double> prod(Map<int, int> x, Map<int, double> y) {
  assert(setEquals(x.keys.toSet(), y.keys.toSet()));
  return x.map((key, value) => MapEntry(key, y[key]!*value));
}

int clamp(int x, int l, int h) {
  return max(l, min(h, x));
}

double log10(num x) {
  return log(x) / log(10);
}
