abstract class Strings {
  static const Set<String> langs = {
    'en', // english
    'zh', // chinese
  };
  static String _lang = 'en';
  static void setLang(String lang) {
    _lang = lang;
  }

  static String _get(final Map<String, String> map) {
    if (map.containsKey(_lang)) {
      return map[_lang]!;
    }
    return map['en']!;
  }

  static const Map<String, String> _pasteInventory = {
    'en': 'Paste Inventory',
  };
  static String get pasteInventory => _get(_pasteInventory);

  static const Map<String, String> _clearInventory = {
    'en': 'Clear Inventory',
  };
  static String get clearInventory => _get(_clearInventory);
}
