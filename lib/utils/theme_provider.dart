import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  ThemeData get currentTheme {
    switch (_themeMode) {
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.light:
      default:
        return AppTheme.lightTheme;
    }
  }
}
