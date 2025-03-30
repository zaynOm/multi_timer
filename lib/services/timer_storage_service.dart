import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/timer_data.dart';

class TimerStorageService {
  static const String _timersKey = 'saved_timers';
  final SharedPreferences _prefs;

  static final TimerStorageService _instance = TimerStorageService._internal();
  static SharedPreferences? _prefsInstance;

  factory TimerStorageService() {
    if (_prefsInstance == null) {
      throw StateError('SharedPreferences not initialized. Call initializePrefs() first.');
    }
    return _instance;
  }

  TimerStorageService._internal() : _prefs = _prefsInstance!;

  static Future<void> initializePrefs() async {
    _prefsInstance = await SharedPreferences.getInstance();
  }

  Future<List<TimerData>> loadTimers() async {
    final String? timersJson = _prefs.getString(_timersKey);
    if (timersJson == null) return [];

    final List<dynamic> decoded = jsonDecode(timersJson);
    return decoded.map((json) => TimerData.fromJson(json)).toList();
  }

  Future<void> saveTimers(List<TimerData> timers) async {
    final String encoded = jsonEncode(timers.map((timer) => timer.toJson()).toList());
    await _prefs.setString(_timersKey, encoded);
  }
}
