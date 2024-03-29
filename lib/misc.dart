import 'dart:math';
import 'math.dart';

class Dura {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  const Dura(this.days, this.hours, this.minutes, this.seconds);
}

Dura secondsToDHMS(num s) {
  if (!s.isFinite) {
    // probably will never happen
    return const Dura(0, 0, 0, 0);
  }
  final d = s ~/ (3600 * 24);
  s -= d * 3600 * 24;
  final h = s ~/ 3600;
  s -= h * 3600;
  final m = s ~/ 60;
  s -= m * 60;
  return Dura(d, h, m, s.round());
}

String prettyPrintSecondsToDH(num _seconds) {
  if (!_seconds.isFinite) {
    // probably will never happen
    return _seconds.toString();
  }
  var dhms = secondsToDHMS(_seconds);
  int days = dhms.days;
  int hours = dhms.hours;
  int minutes = dhms.minutes;
  int seconds = dhms.seconds;
  if (seconds >= 30) {
    minutes += 1;
    seconds = 0;
  }
  if (minutes >= 30) {
    hours += 1;
    minutes = 0;
  }
  if (hours >= 24) {
    days += 1;
    hours = 0;
  }
  String ret = '';
  if (days > 0) {
    // ret += days.toString() + ' days';
    ret += '$days days ';
  }
  if (hours > 0) {
    // ret += ' ' + hours.toString() + ' hours';
    ret += '$hours hours ';
  }
  return ret;
}

int getMaxNumRunsPerLine(int runs, int lines) {
  if (runs == 0) {
    return 0;
  }
  return runs ~/ lines + (runs % lines == 0 ? 0 : 1);
}

double limitCurrencyPrecision(num x) {
  int xi = (x * 100).round();
  int digits = log10(xi).round() - 1;
  int power = pow(10, max(0, digits - 2)).round();
  xi = (xi / power).round();
  xi *= power;
  return xi / 100;
}

String commaFormat(num number) {
  // Globally turn off comma formatting for now
  return number.toString();
  String ret = '';
  final str = number.toString();
  for (int i = 0; i < str.length; i++) {
    if (i % 3 == 0 && i > 0) {
      ret = ',$ret';
    }
    ret = str[str.length - 1 - i] + ret;
  }
  return ret;
}

// TODO make this smart actually
String currencyFormatNumber(
  num isk, {
  bool roundFraction = true,
  bool removeZeroFractionFromString = true,
  bool roundIfOverMillion = true,
  bool roundIfOverHundredThousand = true,
  bool removeFraction = true,
}) {
  if (!isk.isFinite) {
    return isk.toString();
  }
  String ret = '';
  if (roundIfOverMillion && isk.abs() > 0 && log10(isk.abs()).floor() >= 6) {
    int rounded = (isk / pow(10, 6)).round().abs();
    ret = '${commaFormat(rounded)}m';
  } else if (roundIfOverHundredThousand && isk.abs() > 0 && log10(isk.abs()).floor() >= 4) {
    int rounded = (isk / pow(10, 3)).round().abs();
    ret = '${commaFormat(rounded)}k';
  } else {
    final fractionInt = (roundFraction && isk.abs() >= 100) ? 0 : ((isk.abs() - isk.abs().truncate()) * 100).round();
    final fraction = fractionInt >= 10
        ? fractionInt.toString()
        : fractionInt == 0 && (removeZeroFractionFromString  && isk.abs() >= 100)
            ? ''
            : '0$fractionInt';
    final whole = (roundFraction && isk.abs() >= 100) ? isk.abs().round() : isk.abs().truncate();
    ret = commaFormat(whole);
    if (fraction != '' && !(removeFraction && isk.abs() >=100)) {

      ret = '$ret.$fraction';
    }
  }
  if (isk < 0) {
    ret = '-$ret';
  }
  return ret;
}

String percentFormat(double percent) {
  if (!percent.isFinite) {
    return percent.toString();
  }
  return '${(percent * 100).round()}%';
}

String volumeNumberFormat(num vol) {
  if (vol <= 0) {
    return '0';
  }
  if (log10(vol).floor() >= 3) {
    vol = vol / pow(10, 3);
    return '${vol.ceil()}k';
  }
  return commaFormat(vol.round());
}

