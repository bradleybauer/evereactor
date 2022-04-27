import 'dart:math';

import 'package:fraction/fraction.dart';

int ceilDiv(int x, int y) {
  return (x + y - 1) ~/ y;
}

int getNumNeeded(int runs, int slots, int childPerParent, Fraction bonus) {
  final remainder = runs % slots;
  final runsFloor = runs ~/ slots;
  final runsCeil = runsFloor + 1;
  int needed =
      max(runsFloor, ceilDiv(childPerParent * runsFloor * bonus.numerator, bonus.denominator)) * (slots - remainder);
  needed += max(runsCeil, ceilDiv(childPerParent * runsCeil * bonus.numerator, bonus.denominator)) * remainder;
  return needed;
}

double dot(Map<int, double> x, Map<int, double> y) {
  return x.entries.fold(0.0, (double p, e) => p + (y[e.key]??0) * e.value);
}

Map<int,double> prod(Map<int, int> x, Map<int, double> y) {
  return x.map((key, value) => MapEntry(key, y[key]!*value));
}

int clamp(int x, int l, int h) {
  return max(l, min(h, x));
}

double log10(num x) {
  return log(x) / log(10);
}
