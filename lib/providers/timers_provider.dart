import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../models/timer_data.dart';
import '../services/notification_service.dart';
import '../services/timer_storage_service.dart';

class TimerProvider extends ChangeNotifier {
  final List<TimerData> _timers = [];
  final TimerStorageService _storageService;
  final NotificationService _notificationService;
  final bool _soundEnabled = true;
  bool _isInitialized = false;

  TimerProvider(this._storageService, this._notificationService) {
    _notificationService.setOnStopAlarmCallback(_stopAlarmSound);
  }

  List<TimerData> get timers => List.unmodifiable(_timers);

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadSavedTimers();
    _reconcileTimersOnStartup();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadSavedTimers() async {
    final savedTimers = await _storageService.loadTimers();
    _timers.clear();
    _timers.addAll(savedTimers);
    // Removed notifyListeners() here, will be called after reconciliation
  }

  void _reconcileTimersOnStartup() {
    final now = DateTime.now().toUtc();
    bool changed = false;
    for (var timer in _timers) {
      if (timer.scheduledFinishTimeUtc != null && timer.scheduledFinishTimeUtc!.isBefore(now)) {
        // Timer should have fired while app was closed
        timer.remainingSeconds = timer.totalSeconds; // Reset to full duration
        timer.isRunning = false;
        timer.scheduledFinishTimeUtc = null;
        // We don't play sound/show notification here as it should have happened via OS
        // But we ensure the state is correct.
        changed = true;
      } else if (timer.isRunning) {
        // If it was running and saved, it means app was killed.
        // We need to re-schedule notification if it's still in the future.
        if (timer.scheduledFinishTimeUtc != null && timer.scheduledFinishTimeUtc!.isAfter(now)) {
          // Re-calculate remaining seconds based on scheduled finish time
          final remainingDuration = timer.scheduledFinishTimeUtc!.difference(now);
          timer.remainingSeconds =
              remainingDuration.inSeconds > 0 ? remainingDuration.inSeconds : 0;

          if (timer.remainingSeconds == 0) {
            timer.isRunning = false;
            timer.scheduledFinishTimeUtc = null;
          } else {
            // Re-schedule OS notification as a safeguard, though it might already be scheduled
            _scheduleOSNotification(timer);
            // Restart the UI timer
            _startUiTimer(timer);
          }
          changed = true;
        } else {
          // Scheduled time is in the past or null, but was marked as running. Treat as completed.
          timer.remainingSeconds = 0;
          timer.isRunning = false;
          timer.scheduledFinishTimeUtc = null;
          changed = true;
        }
      }
    }
    if (changed) {
      _saveTimers();
    }
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
      final timer = _timers[index];
      _stopAlarmSound(); // Stop sound if it was playing due to this timer
      _cancelOSNotification(timer);
      timer.timer?.cancel();
      _timers.removeAt(index);
      _saveTimers();
      notifyListeners();
    }
  }

  void _startUiTimer(TimerData timer) {
    timer.timer?.cancel(); // Cancel any existing UI timer
    timer.timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timer.remainingSeconds > 0) {
        timer.remainingSeconds--;
        if (timer.remainingSeconds % 30 == 0 && timer.isRunning) {
          // Save periodically only if running
          _saveTimers();
        }
        if (timer.remainingSeconds == 0) {
          timer.isRunning = false;
          timer.timer?.cancel();
          timer.timer = null;
          timer.scheduledFinishTimeUtc = null; // Clear scheduled time
          _playAlarmSound(); // Play sound if app is active
          // UI notification is less critical now, OS notification is primary
          // _showUiNotification(timer.id, timer.label);
          timer.remainingSeconds = timer.totalSeconds; // Reset for next run
          _saveTimers();
        }
        notifyListeners();
      } else {
        // Should not happen if logic is correct, but as a safeguard
        timer.isRunning = false;
        timer.timer?.cancel();
        timer.timer = null;
        timer.scheduledFinishTimeUtc = null;
        _saveTimers();
        notifyListeners();
      }
    });
  }

  void toggleTimer(String id) {
    final index = _timers.indexWhere((timer) => timer.id == id);
    if (index != -1) {
      final timer = _timers[index];

      // If timer finished and is being toggled, it means user wants to restart or stop alarm
      if (timer.remainingSeconds <= 0 && !timer.isRunning) {
        _stopAlarmSound();
        _cancelOSNotification(timer); // Cancel any lingering OS notification
        timer.remainingSeconds = timer.totalSeconds; // Reset before starting
      }

      timer.isRunning = !timer.isRunning;

      if (timer.isRunning) {
        // If remainingSeconds is 0 when starting, reset it to totalSeconds
        if (timer.remainingSeconds <= 0) {
          timer.remainingSeconds = timer.totalSeconds;
        }
        timer.scheduledFinishTimeUtc = DateTime.now().add(
          Duration(seconds: timer.remainingSeconds),
        );
        _scheduleOSNotification(timer);
        _startUiTimer(timer);
      } else {
        timer.timer?.cancel();
        timer.timer = null;
        _cancelOSNotification(timer);
        // When pausing, we don't clear scheduledFinishTimeUtc immediately,
        // because if the app is killed, we want to know when it *was* supposed to finish.
        // However, for saving, we might want to clear it or handle it.
        // For now, let's clear it to prevent re-scheduling an old time if app restarts.
        // timer.scheduledFinishTimeUtc = null; // Let's test this behavior.
        // On second thought, let's keep scheduledFinishTimeUtc when paused.
        // The reconciliation logic will handle it if app restarts.
      }
      _saveTimers();
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
      _stopAlarmSound();
      _cancelOSNotification(timer);
      timer.scheduledFinishTimeUtc = null; // Clear scheduled time on reset
      _saveTimers();
      notifyListeners();
    }
  }

  void _scheduleOSNotification(TimerData timer) {
    if (timer.remainingSeconds <= 0) return;

    final int notificationId = int.parse(timer.id.substring(0, 8), radix: 16) % 100000;
    final scheduledDateTime = DateTime.now().add(Duration(seconds: timer.remainingSeconds));
    timer.scheduledFinishTimeUtc = scheduledDateTime.toUtc(); // Store UTC

    _notificationService.scheduleTimerNotification(
      id: notificationId,
      title: 'Timer Complete!',
      body: '${timer.label} has finished.',
      scheduledDateTime: scheduledDateTime,
      payload: timer.id, // Use timer.id as payload to identify it
    );
  }

  void _cancelOSNotification(TimerData timer) {
    final int notificationId = int.parse(timer.id.substring(0, 8), radix: 16) % 100000;
    _notificationService.cancelNotification(notificationId);
    // timer.scheduledFinishTimeUtc = null; // Clearing this here might be too aggressive,
    // let save/load handle persistence.
    // It's cleared on explicit reset/delete or completion.
  }

  void _playAlarmSound() {
    if (_soundEnabled) {
      _stopAlarmSound();
      FlutterRingtonePlayer().playAlarm(looping: true);
    }
  }

  void _stopAlarmSound() {
    FlutterRingtonePlayer().stop();
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.timer?.cancel();
    }
    super.dispose();
  }
}
