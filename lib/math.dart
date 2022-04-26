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
