import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_service.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  late final SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = SharedPreferencesService.instance;
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
    _initialized = true;
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }
}
