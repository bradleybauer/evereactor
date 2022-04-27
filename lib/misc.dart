import 'dart:math';

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
    ret += days.toString() + ' / ';
  }
  if (hours > 0) {
    // ret += ' ' + hours.toString() + ' hours';
    ret += hours.toString();
  }
  return ret;
}

int getMaxNumRunsPerLine(int runs, int lines) {
  if (runs == 0) {
    return 0;
  }
  return runs ~/ lines + (runs % lines == 0 ? 0 : 1);
}

int clamp(int x, int l, int h) {
  return max(l, min(h, x));
}

double log10(num x) {
  return log(x) / log(10);
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
      ret = ',' + ret;
    }
    ret = str[str.length - 1 - i] + ret;
  }
  return ret;
}

String currencyFormatNumber(
  num isk, {
  bool roundFraction = true,
  bool removeZeroFractionFromString = true,
  bool roundBigIskToMillions = true,
  bool removeFraction = true,
}) {
  if (!isk.isFinite) {
    return isk.toString();
  }
  String ret = '';
  if (roundBigIskToMillions && isk.abs() > 0 && log10(isk.abs()).floor() >= 6) {
    int rounded = (isk / pow(10, 6)).round().abs();
    ret = commaFormat(rounded) + 'm';
  } else if (roundBigIskToMillions && isk.abs() > 0) {
    if (isk.abs() < 49999) {
      return '0';
    }
    int rounded = (isk / pow(10, 6) * 10).round().abs();
    String roundedStr = rounded.toString();
    if (roundedStr.endsWith('0')) {
      roundedStr = roundedStr[0];
    }
    ret = '0.' + roundedStr + 'm';
  } else {
    final fractionInt = roundFraction ? 0 : ((isk.abs() - isk.abs().truncate()) * 100).round();
    final fraction = fractionInt >= 10
        ? fractionInt.toString()
        : fractionInt == 0 && removeZeroFractionFromString
            ? ''
            : '0' + fractionInt.toString();
    final whole = roundFraction ? isk.abs().round() : isk.abs().truncate();
    ret = commaFormat(whole);
    if (fraction != '' && !removeFraction) {
      ret = ret + '.' + fraction;
    }
  }
  if (isk < 0) {
    ret = '-' + ret;
  }
  return ret;
}

String percentFormat(double percent) {
  if (!percent.isFinite) {
    return percent.toString();
  }
  return (percent * 100).round().toString() + '%';
}

String volumeNumberFormat(num vol) {
  if (vol <= 0) {
    return '0';
  }
  if (log10(vol).floor() >= 3) {
    vol = vol / pow(10, 3);
    return vol.ceil().toString() + 'k';
  }
  return commaFormat(vol.round());
}

