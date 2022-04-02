import 'package:flutter/material.dart';

// https://m3.material.io/styles/color/the-color-system/key-colors-tones
class MyTheme with ChangeNotifier {
  static bool _inDarkMode = false;
  // static const darkThemeSeedColor = Color.fromARGB(255, 242, 255, 0);
  // static const lightThemeSeedColor = Color.fromARGB(255, 18, 157, 195);
  static const lightThemeSeedColor = Color.fromARGB(255, 242, 255, 0);
  static const darkThemeSeedColor = Color.fromARGB(255, 18, 157, 195);

  static const double appHeight = 1000;
  static const double appWidth = 800;
  static const double appBarTextButtonHeight = 27;
  static const double appBarPadding = 20;

  // static const TextStyle typo;
  //TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w600, color: theme.colors.onPrimary)

  ThemeMode get mode => _inDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _inDarkMode = !_inDarkMode;
    notifyListeners();
  }

  get _seedColor => _inDarkMode ? darkThemeSeedColor : lightThemeSeedColor;

  // Return the Material Design 3 color scheme generated from [_seedColor].
  ColorScheme get colors => ColorScheme.fromSeed(seedColor: _seedColor, brightness: _inDarkMode ? Brightness.dark : Brightness.light);

  ThemeData get theme => ThemeData.from(colorScheme: colors).copyWith(useMaterial3: true);
}

MyTheme theme = MyTheme();
