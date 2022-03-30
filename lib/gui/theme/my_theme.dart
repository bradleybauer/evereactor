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
    //1
    return ThemeData(
      //2
      primaryColor: MyColors.black,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Montserrat', //3
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: MyColors.black,
      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'Montserrat',
      textTheme: ThemeData.dark().textTheme,
    );
  }
}
