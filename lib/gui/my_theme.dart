import 'package:flutter/material.dart';

class MyTheme with ChangeNotifier {
  static const darkThemeSeedColor = Color.fromARGB(255, 242, 255, 0);
  static const lightThemeSeedColor = Color.fromRGBO(18, 157, 195, 1);

  bool _inDarkMode = true;
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
