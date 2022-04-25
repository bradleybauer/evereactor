import 'package:flutter/material.dart';

class Strings with ChangeNotifier {
  // TODO should have localized font sizes as well.
  // TODO super-mega-chad-ultracoder-ambition idea would be to have localized widget sizes as well
  //      (search bar is too wide when using chinese because chinese is more dense than english...
  //      similar idea for table column widths/heights (could make rows more compact))
  static const Map<String, Map<String, String>> langNames = {
    'en': {'en': 'English'},
    'zh': {'en': 'Chinese'},
  };
  static String _lang = 'en';

  void setLang(String lang) {
    _lang = lang;
    notifyListeners();
  }

  static String get(final Map<String, String> map) {
    if (map.containsKey(_lang)) {
      return map[_lang]!;
    }
    return map['en']!;
  }

  static const Map<String, String> _pasteInventory = {
    'en': 'Paste Inventory',
  };

  static String get pasteInventory => get(_pasteInventory);

  static const Map<String, String> _clearInventory = {
    'en': 'Clear Inventory',
  };

  static String get clearInventory => get(_clearInventory);

  static const Map<String, String> _getMarketData = {
    'en': 'Get Market Data',
  };

  static String get getMarketData => get(_getMarketData);

  static String getLang() => _lang;
}
