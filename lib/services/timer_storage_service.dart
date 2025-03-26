import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/timer_data.dart';

class TimerStorageService {
  static const String _timersKey = 'saved_timers';

  // Save a list of timers to local storage
  Future<bool> saveTimers(List<TimerData> timers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = timers.map((timer) => timer.toJson()).toList();
      final jsonString = jsonEncode(jsonData);

      return await prefs.setString(_timersKey, jsonString);
    } catch (e) {
      print('Error saving timers: $e');
      return false;
    }
  }

  // Load timers from local storage
  Future<List<TimerData>> loadTimers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_timersKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonData = jsonDecode(jsonString) as List;
      return jsonData
          .map((item) => TimerData.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading timers: $e');
      return [];
    }
  }

  // Clear all saved timers
  Future<bool> clearTimers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_timersKey);
    } catch (e) {
      print('Error clearing timers: $e');
      return false;
    }
  }
}
