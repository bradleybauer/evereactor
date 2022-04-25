import 'package:flutter/material.dart';

// https://m3.material.io/styles/color/the-color-system/key-colors-tones
class MyTheme with ChangeNotifier {
  MyTheme() {
    setColor(const Color.fromARGB(255, 184, 91, 91), notify:false);
  }

  bool _inDarkMode = true;
  late Color _seedColor;
  // Return the Material Design 3 color scheme generated from [_seedColor].
  // static ColorScheme get colors => ColorScheme.fromSeed(seedColor: _seedColor, brightness: _inDarkMode ? Brightness.dark : Brightness.light);
  late ColorScheme _colors;

  // This one line is why the TextField outline border changes to a nice color when clicked. Nice!
  ThemeData theme = ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.black)).copyWith(useMaterial3: true);

  get isDark => _inDarkMode;

  Color primary = Colors.black;
  Color onPrimary = Colors.black;
  Color primaryContainer = Colors.black;
  Color onPrimaryContainer = Colors.black;
  Color secondary = Colors.black;
  Color onSecondary = Colors.black;
  Color secondaryContainer = Colors.black;
  Color onSecondaryContainer = Colors.black;
  Color tertiary = Colors.black;
  Color onTertiary = Colors.black;
  Color tertiaryContainer = Colors.black;
  Color onTertiaryContainer = Colors.black;
  Color background = Colors.black;
  Color onBackground = Colors.black;
  Color surface = Colors.black;
  Color onSurface = Colors.black;
  Color surfaceVariant = Colors.black;
  Color onSurfaceVariant = Colors.black;
  Color error = Colors.black;
  Color onError = Colors.black;
  Color errorContainer = Colors.black;
  Color onErrorContainer = Colors.black;
  Color outline = Colors.black;
  Color shadow = Colors.black;

  void toggleLightDark() {
    _inDarkMode = !_inDarkMode;
    setColor(_seedColor);
  }

  Color getColor() => _seedColor;

  void setColor(Color color,{bool notify=true}) {
    // _inDarkMode = !_inDarkMode;
    _seedColor = color;
    _colors =
        ColorScheme.fromSeed(seedColor: _seedColor, brightness: _inDarkMode ? Brightness.dark : Brightness.light);
    theme = ThemeData.from(colorScheme: _colors).copyWith(useMaterial3: true);
    primary = _colors.primary;
    onPrimary = _colors.onPrimary;
    primaryContainer = _colors.primaryContainer;
    onPrimaryContainer = _colors.onPrimaryContainer;
    secondary = _colors.secondary;
    onSecondary = _colors.onSecondary;
    secondaryContainer = _colors.secondaryContainer;
    onSecondaryContainer = _colors.onSecondaryContainer;
    tertiary = _colors.tertiary;
    onTertiary = _colors.onTertiary;
    tertiaryContainer = _colors.tertiaryContainer;
    onTertiaryContainer = _colors.onTertiaryContainer;
    background = _colors.background;
    onBackground = _colors.onBackground;
    surface = _colors.surface;
    onSurface = _colors.onSurface;
    surfaceVariant = _colors.surfaceVariant;
    onSurfaceVariant = _colors.onSurfaceVariant;
    error = _colors.error;
    onError = _colors.onError;
    errorContainer = _colors.errorContainer;
    onErrorContainer = _colors.onErrorContainer;
    outline = _colors.outline;
    shadow = _colors.shadow;
    if (notify) {
      notifyListeners();
    }
  }

  Color on(Color c) {
    if (c == _colors.primary) {
      return _colors.onPrimary;
    } else if (c == _colors.primaryContainer) {
      return _colors.onPrimaryContainer;
    } else if (c == _colors.secondary) {
      return _colors.onSecondary;
    } else if (c == _colors.secondaryContainer) {
      return _colors.onSecondaryContainer;
    } else if (c == _colors.tertiary) {
      return _colors.onTertiary;
    } else if (c == _colors.tertiaryContainer) {
      return _colors.onTertiaryContainer;
    } else if (c == _colors.background) {
      return _colors.onBackground;
    } else if (c == _colors.surface) {
      return _colors.onSurface;
    } else if (c == _colors.surfaceVariant) {
      return _colors.onSurfaceVariant;
    } else if (c == _colors.error) {
      return _colors.onError;
    } else if (c == _colors.errorContainer) {
      return _colors.onErrorContainer;
    } else if (c == _colors.outline) {
      return _colors.outline;
    } else if (c == _colors.shadow) {
      return _colors.shadow;
    } else {
      assert(false);
      return Colors.black;
    }
  }

  static const Duration buttonFocusDuration = Duration(milliseconds: 200);

  // Looks like NotoSans is using FontFeature.tabularNumbers by default. I am going to specify it anyway though
  // because I have not tested for different languages yet.
  // const TextStyle typo;
  // TextStyle(fontFeatures: [FontFeature.tabularFigures(), FontFeature.alternative(0)]);
  //TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w600, color: theme.colors.onPrimary)

  static const double appMinHeight = 500;
  static const double appWidth = 1000;
  static const double appBarButtonHeight = 28;
  static const double appBarHeight = 48;
  static const double appBarPadding = 10;
}

// MyTheme theme = MyTheme();
typedef theme = MyTheme;
