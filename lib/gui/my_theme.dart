import 'package:flutter/material.dart';

// https://m3.material.io/styles/color/the-color-system/key-colors-tones
abstract class MyTheme {
  //with ChangeNotifier {
  // static bool _inDarkMode = true;
  static const bool _inDarkMode = false;

  static const lightThemeSeedColor = Color.fromARGB(255, 255, 255, 255);
  static const darkThemeSeedColor = Color.fromARGB(255, 0, 0, 0);
  // static const lightThemeSeedColor = Color.fromARGB(255, 242, 255, 0);
  // static const darkThemeSeedColor = Color.fromARGB(255, 18, 157, 195);
  // static const lightThemeSeedColor = Color.fromARGB(255, 184, 91, 91);
  // static const darkThemeSeedColor = Color.fromARGB(255, 18, 157, 195);

  // static ThemeMode get mode => _inDarkMode ? ThemeMode.dark : ThemeMode.light;

  static on(Color c) {
    // switch(c) {
    //   case colors.
    // }
  }

  // void toggleTheme() {
  //   _inDarkMode = !_inDarkMode;
  //   notifyListeners();
  // }

  static get _seedColor => _inDarkMode ? darkThemeSeedColor : lightThemeSeedColor;

  // Return the Material Design 3 color scheme generated from [_seedColor].
  // static ColorScheme get colors => ColorScheme.fromSeed(seedColor: _seedColor, brightness: _inDarkMode ? Brightness.dark : Brightness.light);
  static ColorScheme colors = ColorScheme.fromSeed(seedColor: _seedColor, brightness: _inDarkMode ? Brightness.dark : Brightness.light);

  static ThemeData get theme => ThemeData.from(colorScheme: colors).copyWith(useMaterial3: true);

  static const Duration buttonFocusDuration = Duration(milliseconds: 200);

  // static const TextStyle typo;
  //TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w600, color: theme.colors.onPrimary)

  static const double appMinHeight = 400;
  static const double appWidth = 1000;

  static const double appBarButtonHeight = 28;
  static const double appBarHeight = 48;
  static const double appBarPadding = 10;
}

// MyTheme theme = MyTheme();
typedef theme = MyTheme;
