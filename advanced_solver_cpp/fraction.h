#pragma once

#include <numeric>

// this class works for my use case (everything positive, no zero denominators)
class Fraction {
public:
  int64_t num;
  int64_t den;
  Fraction(int64_t num, int64_t den) : num(num), den(den) {
    const int64_t gcd = std::gcd(num, den);
    num /= gcd;
    den /= gcd;
  }
  Fraction(int64_t num) : num(num), den(1) {}
  Fraction() :num(0),den(1) {}

  Fraction operator-(const Fraction& r) { return Fraction(num * r.den - den * r.num, den * r.den); }

  Fraction operator*(const int64_t i) { return Fraction(num * i, den); }

  double toDouble() const { return num / double(den); }

  int64_t toIntCeil() const { return (num + den - 1) / den; }
  int64_t toIntFloor() const { return num / den; }

  bool operator>(const Fraction& r) const { return toDouble() > r.toDouble(); }
  bool operator<(const Fraction& r) const { return toDouble() < r.toDouble(); }
};