import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../models/timer_data.dart';
import 'notification_service.dart';
import 'timer_storage_service.dart';

class TimerService extends ChangeNotifier {
  final List<TimerData> _timers = [];
  final TimerStorageService _storageService = TimerStorageService();
  final NotificationService _notificationService = NotificationService();
  final bool _soundEnabled = true;
  bool _isInitialized = false;

  TimerService() {
    _notificationService.setOnStopAlarmCallback(_stopAlarmSound);
  }

  List<TimerData> get timers => List.unmodifiable(_timers);

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadSavedTimers();
    _isInitialized = true;
  }

  Future<void> _loadSavedTimers() async {
    final savedTimers = await _storageService.loadTimers();
    _timers.clear();
    _timers.addAll(savedTimers);
    notifyListeners();
  }

  Future<void> _saveTimers() async {
    await _storageService.saveTimers(_timers);
  }

  // Add a new timer
  void addTimer(String label, int hours, int minutes, int seconds, {Color? color}) {
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;
    final newTimer = TimerData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      totalSeconds: totalSeconds,
      color: color ?? _getNextColor(), // Use provided color or get next color
    );
    _timers.add(newTimer);
    _saveTimers();
    notifyListeners();
  }

  // Helper method to get a color from our predefined list
  Color _getNextColor() {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];
    return colors[_timers.length % colors.length];
  }

  void deleteTimer(String id) {
    final index = _timers.indexWhere((timer) => timer.id == id);
    if (index != -1) {
      if (_timers[index].remainingSeconds <= 0) {
        _stopAlarmSound();
        final int notificationId = int.parse(id.substring(0, 8), radix: 16) % 100000;
        _notificationService.cancelNotification(notificationId);
      }
      _timers[index].timer?.cancel();
      _timers.removeAt(index);
      _saveTimers();
      notifyListeners();
    }
  }

  void toggleTimer(String id) {
    final index = _timers.indexWhere((timer) => timer.id == id);
    if (index != -1) {
      final timer = _timers[index];

      if (timer.remainingSeconds <= 0) {
        _stopAlarmSound();
        final int notificationId = int.parse(id.substring(0, 8), radix: 16) % 100000;
        _notificationService.cancelNotification(notificationId);
      }

      timer.isRunning = !timer.isRunning;
      if (timer.isRunning) {
        timer.timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (timer.remainingSeconds > 0) {
            timer.remainingSeconds--;
            if (timer.remainingSeconds % 30 == 0) {
              _saveTimers();
            }
            if (timer.remainingSeconds == 0) {
              timer.isRunning = false;
              timer.timer?.cancel();
              timer.timer = null;
              _playAlarmSound();
              _showNotification(timer.id, timer.label);
              timer.remainingSeconds = timer.totalSeconds;
              _saveTimers();
            }
            notifyListeners();
          }
        });
      } else {
        timer.timer?.cancel();
        timer.timer = null;
        _saveTimers();
      }
      notifyListeners();
    }
  }

  void resetTimer(String id) {
    final index = _timers.indexWhere((timer) => timer.id == id);
    if (index != -1) {
      final timer = _timers[index];
      timer.timer?.cancel();
      timer.timer = null;
      timer.isRunning = false;
      timer.remainingSeconds = timer.totalSeconds;

      if (timer.remainingSeconds <= 0) {
        _stopAlarmSound();
        final int notificationId = int.parse(id.substring(0, 8), radix: 16) % 100000;
        _notificationService.cancelNotification(notificationId);
      }
      _saveTimers();
      notifyListeners();
    }
  }

  void _playAlarmSound() {
    if (_soundEnabled) {
      _stopAlarmSound();
      FlutterRingtonePlayer().playAlarm();
    }
  }

  void _stopAlarmSound() {
    FlutterRingtonePlayer().stop();
  }

  Future<void> _showNotification(String id, String timerLabel) async {
    final int notificationId = int.parse(id.substring(0, 8), radix: 16) % 100000;
    await _notificationService.showTimerNotification(
      id: notificationId,
      title: 'Timer Complete',
      body: '$timerLabel has finished',
      payload: 'stop_alarm',
    );
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.timer?.cancel();
    }
    super.dispose();
  }
}
