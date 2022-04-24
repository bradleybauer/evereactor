import 'package:flutter/material.dart';

import '../models/options.dart';
import '../strings.dart';
import 'market.dart';

class OptionsAdapter with ChangeNotifier {
  final Options _options;

  final MarketAdapter _market;

  OptionsAdapter(this._options, this._market, Strings strings) {
    _market.addListener(() {
      notifyListeners();
    });

    strings.addListener(() {
      notifyListeners();
    });
  }
}

class SkillsData {
  final int tid;
  final String name;
  final int level;

  const SkillsData(this.tid, this.name, this.level);
}
