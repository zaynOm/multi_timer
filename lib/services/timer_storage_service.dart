import 'dart:convert';

import 'package:multi_timer/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/timer_data.dart';

class TimerStorageService {
  static const String _timersKey = 'saved_timers';
  late final SharedPreferencesAsync _prefs;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = getIt<SharedPreferencesAsync>();
    _initialized = true;
  }

  Future<List<TimerData>> loadTimers() async {
    if (!_initialized) await initialize();
    final String? timersJson = await _prefs.getString(_timersKey);
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
