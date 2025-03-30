import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/timer_data.dart';
import 'shared_preferences_service.dart';

class TimerStorageService {
  static const String _timersKey = 'saved_timers';
  late final SharedPreferences _prefs;
  static final TimerStorageService _instance = TimerStorageService._internal();
  bool _initialized = false;

  factory TimerStorageService() {
    return _instance;
  }

  TimerStorageService._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferencesService.instance;
    _initialized = true;
  }

  Future<List<TimerData>> loadTimers() async {
    if (!_initialized) await initialize();
    final String? timersJson = _prefs.getString(_timersKey);
    if (timersJson == null) return [];
    final List<dynamic> decoded = jsonDecode(timersJson);
    return decoded.map((json) => TimerData.fromJson(json)).toList();
  }

  Future<void> saveTimers(List<TimerData> timers) async {
    if (!_initialized) await initialize();
    final String encoded = jsonEncode(timers.map((timer) => timer.toJson()).toList());
    await _prefs.setString(_timersKey, encoded);
  }
}
