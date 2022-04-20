import 'dart:math';
import 'models/build_options.dart';
import 'models/market_order.dart';

import 'package:tuple/tuple.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// https://cdn1.eveonline.com/www/newssystem/media/66437/1/rounding.png
int calcBonusedMaterialAmount(int numRunsParent, int baseNumInputChild, BuildOptions env) {
  return (numRunsParent * baseNumInputChild * (1.0 - env.structureMaterialBonus)).ceil();
}

Tuple4<int, int, int, int> secondsToDHMS(num s) {
  if (!s.isFinite) {
    // probably will never happen
    return const Tuple4(0, 0, 0, 0);
  }
  final d = s ~/ (3600 * 24);
  s -= d * 3600 * 24;
  final h = s ~/ 3600;
  s -= h * 3600;
  final m = s ~/ 60;
  s -= m * 60;
  return Tuple4(d, h, m, s.round());
}

double calcBonusedTimeSeconds(int runs, int base, int reactionsSkill, double structureTimeBonus) {
  return runs * base * (1 - .04 * reactionsSkill) * (1 - structureTimeBonus);
}

void combineMaps(Map<int, int> a, Map<int, int> b) {
  for (var entry in b.entries) {
    if (a.containsKey(entry.key)) {
      a[entry.key] = a[entry.key]! + entry.value;
    } else {
      a[entry.key] = entry.value;
    }
  }
}

String prettyPrintSecondsToDH(num _seconds) {
  if (!_seconds.isFinite) {
    // probably will never happen
    return _seconds.toString();
  }
  var dhms = secondsToDHMS(_seconds);
  int days = dhms.item1;
  int hours = dhms.item2;
  int minutes = dhms.item3;
  int seconds = dhms.item4;
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

// TODO this can fuck up so do a try except here
Future<Map<int, double>> getAdjustedPricesESI(List<int> ids) async {
  print('Fetching');
  var response = await http.get(Uri.parse('https://esi.evetech.net/latest/markets/prices/?datasource=tranquility'));
  var data = jsonDecode(response.body);
  Map<int, double> ret = {};
  for (var x in data) {
    if (ids.contains(x['type_id'])) {
      ret[x['type_id']] = x['adjusted_price'];
    }
  }
  print('Done');
  return ret;
}

Future<Map<int, List<Order>>> getOrdersFromESI(List<int> ids) async {
  print('Fetching orders');
  List<int> region_ids = [
    // Constants.THE_FORGE_REGION_ID,
    // Constants.DOMAIN_REGION_ID,
    // Constants.SINQ_LAISON_REGION_ID,
    // Constants.METROPOLIS_REGION_ID,
  ];
  Map<int, List<Order>> ret = {};
  for (int id in ids) {
    if (!ret.containsKey(id)) {
      ret[id] = [];
    }
  }
  for (var id in ids) {
    print('ids:' + id.toString());
    for (int region_id in region_ids) {
      String url = 'https://esi.evetech.net/latest/markets/' + region_id.toString() + '/orders/';
      int page = 1;
      var response =
          await http.get(Uri.parse(url + '?datasource=tranquility&order_type=all&page=' + page.toString() + '&type_id=' + id.toString()));
      var data = jsonDecode(response.body);
      while (data.length > 0) {
        try {
          for (var x in data) {
            // print(x['type_id'].toString() + '\t' + x['price'].toString() + '\t' + x['volume_remain'].toString());
            ret[x['type_id']]!.add(Order(x['type_id'], x['system_id'], region_id, x['is_buy_order'], x['price'], x['volume_remain']));
          }
          print('page:' + page.toString());
          var response =
              await http.get(Uri.parse(url + '?datasource=tranquility&order_type=all&page=' + page.toString() + '&type_id=' + id.toString()));
          data = jsonDecode(response.body);
          page += 1;
        } catch (e) {
          break;
        }
      }
    }
  }
  print('Done fetching orders');
  return ret;
}
