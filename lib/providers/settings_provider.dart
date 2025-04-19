import 'package:flutter/material.dart';
import 'package:multi_timer/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _isSoundEnabledKey = 'is_sound_enabled';
  static const String _isVibrationEnabledKey = 'is_vibration_enabled';
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;
  late final SharedPreferencesAsync _prefs;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = getIt<SharedPreferencesAsync>();
    final savedTheme = await _prefs.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
    _isSoundEnabled = await _prefs.getBool(_isSoundEnabledKey) ?? true;
    _isVibrationEnabled = await _prefs.getBool(_isVibrationEnabledKey) ?? true;
    _initialized = true;
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;

  Future<void> toggleSound(bool value) async {
    _isSoundEnabled = value;
    await _prefs.setBool(_isSoundEnabledKey, value);
    notifyListeners();
  }

  Future<void> toggleVibration(bool value) async {
    _isVibrationEnabled = value;
    await _prefs.setBool(_isVibrationEnabledKey, value);
    notifyListeners();
  }
}
