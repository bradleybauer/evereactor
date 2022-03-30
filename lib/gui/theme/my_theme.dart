import 'package:flutter/material.dart';

import 'colors.dart';

class MyTheme with ChangeNotifier {
  static bool _isDarkTheme = true;
  ThemeMode get currentTheme => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: MyColors.black,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'SauceCodeProMono',
      textTheme: ThemeData.light().textTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: MyColors.black,
      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'SauceCodeProMono',
      textTheme: ThemeData.dark().textTheme,
    );
  }
}
