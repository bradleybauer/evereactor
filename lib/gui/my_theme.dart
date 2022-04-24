import 'package:flutter/material.dart';

// https://m3.material.io/styles/color/the-color-system/key-colors-tones
abstract class MyTheme {
  //with ChangeNotifier {
  static const bool _inDarkMode = false;

  // static const lightThemeSeedColor = Color.fromARGB(255, 255, 255, 255);
  // static const darkThemeSeedColor = Color.fromARGB(255, 0, 0, 0);

  // static const lightThemeSeedColor = Color.fromARGB(255, 242, 255, 0);
  // static const darkThemeSeedColor = Color.fromARGB(255, 18, 157, 195);

  static const lightThemeSeedColor = Color.fromARGB(255, 184, 91, 91);
  static const darkThemeSeedColor = Color.fromARGB(255, 41, 195, 102);

  // static ThemeMode get  mode => _inDarkMode ? ThemeMode.dark : ThemeMode.light;

  // void toggleTheme() {
  //   _inDarkMode = !_inDarkMode;
  //   notifyListeners();
  // }

  static get _seedColor => _inDarkMode ? darkThemeSeedColor : lightThemeSeedColor;

  // Return the Material Design 3 color scheme generated from [_seedColor].
  // static ColorScheme get colors => ColorScheme.fromSeed(seedColor: _seedColor, brightness: _inDarkMode ? Brightness.dark : Brightness.light);
  static ColorScheme colors = ColorScheme.fromSeed(seedColor: _seedColor, brightness: _inDarkMode ? Brightness.dark : Brightness.light);

  // This one line is why the TextField outline border changes to a nice color when clicked. Nice!
  static ThemeData get theme => ThemeData.from(colorScheme: colors).copyWith(useMaterial3: true);

  static const Duration buttonFocusDuration = Duration(milliseconds: 200);

  // Looks like NotoSans is using FontFeature.tabularNumbers by default. I am going to specify it anyway though
  // because I have not tested for different languages yet.
  // static const TextStyle typo;
  // TextStyle(fontFeatures: [FontFeature.tabularFigures(), FontFeature.alternative(0)]);
  //TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w600, color: theme.colors.onPrimary)

  static const double appMinHeight = 500;
  static const double appWidth = 1000;

  static const double appBarButtonHeight = 28;
  static const double appBarHeight = 48;
  static const double appBarPadding = 10;

  static Color on(Color c) {
    if (c == colors.primary) {
      return colors.onPrimary;
    } else if (c == colors.primaryContainer) {
      return colors.onPrimaryContainer;
    } else if (c == colors.secondary) {
      return colors.onSecondary;
    } else if (c == colors.secondaryContainer) {
      return colors.onSecondaryContainer;
    } else if (c == colors.tertiary) {
      return colors.onTertiary;
    } else if (c == colors.tertiaryContainer) {
      return colors.onTertiaryContainer;
    } else if (c == colors.background) {
      return colors.onBackground;
    } else if (c == colors.surface) {
      return colors.onSurface;
    } else if (c == colors.surfaceVariant) {
      return colors.onSurfaceVariant;
    } else if (c == colors.error) {
      return colors.onError;
    } else if (c == colors.errorContainer) {
      return colors.onErrorContainer;
    } else {
      assert(false);
      return Colors.black;
    }
  }

  static Color get primary => colors.primary;
  static Color get onPrimary => colors.onPrimary;
  static Color get primaryContainer => colors.primaryContainer;
  static Color get onPrimaryContainer => colors.onPrimaryContainer;
  static Color get secondary => colors.secondary;
  static Color get onSecondary => colors.onSecondary;
  static Color get secondaryContainer => colors.secondaryContainer;
  static Color get onSecondaryContainer => colors.onSecondaryContainer;
  static Color get tertiary => colors.tertiary;
  static Color get onTertiary => colors.onTertiary;
  static Color get tertiaryContainer => colors.tertiaryContainer;
  static Color get onTertiaryContainer => colors.onTertiaryContainer;
  static Color get background => colors.background;
  static Color get onBackground => colors.onBackground;
  static Color get surface => colors.surface;
  static Color get onSurface => colors.onSurface;
  static Color get surfaceVariant => colors.surfaceVariant;
  static Color get onSurfaceVariant => colors.onSurfaceVariant;
  static Color get error => colors.error;
  static Color get onError => colors.onError;
  static Color get errorContainer => colors.errorContainer;
  static Color get onErrorContainer => colors.onErrorContainer;
  static Color get outline => colors.outline;
  static Color get shadow => colors.shadow;
}

// MyTheme theme = MyTheme();
typedef theme = MyTheme;
