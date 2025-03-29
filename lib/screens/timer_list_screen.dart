import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../models/timer_data.dart';
import '../services/notification_service.dart';
import '../services/timer_storage_service.dart';
import '../widgets/time_wheel_picker.dart';
import '../widgets/timer_card.dart';

class TimerListScreen extends StatefulWidget {
  const TimerListScreen({super.key});

  @override
  State<TimerListScreen> createState() => _TimerListScreenState();
}

class _TimerListScreenState extends State<TimerListScreen> {
  final List<TimerData> _timers = [];
  final bool _soundEnabled = true;
  final _notificationService = NotificationService();
  final _storageService = TimerStorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadSavedTimers();
  }

  Future<void> _loadSavedTimers() async {
    setState(() {
      _isLoading = true;
    });

    final savedTimers = await _storageService.loadTimers();

    setState(() {
      _timers.clear();
      _timers.addAll(savedTimers);
      _isLoading = false;
    });
  }

  // Save timers to local storage
  Future<void> _saveTimers() async {
    await _storageService.saveTimers(_timers);
  }

  void _initNotifications() async {
    await _notificationService.initialize(
      onNotificationTap: (NotificationResponse response) {
        if (response.actionId == stopSoundAction || response.payload == 'stop_alarm') {
          _stopAlarmSound();
        }
      },
      stopSoundCallback: _stopAlarmSound,
    );
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.timer?.cancel();
    }
    super.dispose();
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

  void _addTimer(String label, int hours, int minutes, int seconds) {
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;
    if (totalSeconds <= 0) return;

    setState(() {
      _timers.add(
        TimerData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: label,
          totalSeconds: totalSeconds,
        ),
      );
    });
    _saveTimers();
  }

  void _deleteTimer(String id) {
    setState(() {
      final index = _timers.indexWhere((timer) => timer.id == id);
      if (index != -1) {
        // If this is the timer that's currently playing an alarm, stop it
        if (_timers[index].remainingSeconds <= 0) {
          _stopAlarmSound();
          // Cancel any notifications for this timer
          final int notificationId = int.parse(id.substring(0, 8), radix: 16) % 100000;
          _notificationService.cancelNotification(notificationId);
        }
        _timers[index].timer?.cancel();
        _timers.removeAt(index);
      }
    });
    _saveTimers();
  }

  void _toggleTimer(String id) {
    setState(() {
      final index = _timers.indexWhere((timer) => timer.id == id);
      if (index != -1) {
        final timer = _timers[index];

        // If the timer was completed and we're toggling it, make sure to stop any ongoing alarms
        if (timer.remainingSeconds <= 0) {
          _stopAlarmSound();
          final int notificationId = int.parse(id.substring(0, 8), radix: 16) % 100000;
          _notificationService.cancelNotification(notificationId);
        }

        timer.isRunning = !timer.isRunning;
        if (timer.isRunning) {
          timer.timer = Timer.periodic(const Duration(seconds: 1), (t) {
            setState(() {
              if (timer.remainingSeconds > 0) {
                timer.remainingSeconds--;
                // Save timers periodically (every 30 seconds) to capture progress
                if (timer.remainingSeconds % 30 == 0) {
                  _saveTimers();
                }
                // Check if timer just finished
                if (timer.remainingSeconds == 0) {
                  timer.isRunning = false;
                  timer.timer?.cancel();
                  timer.timer = null;
                  _playAlarmSound();
                  _showNotification(timer.id, timer.label);

                  // Auto-reset the timer when it completes
                  timer.remainingSeconds = timer.totalSeconds;

                  _saveTimers(); // Save when timer finishes

                  // Show in-app notification
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${timer.label} timer is complete!'),
                        action: SnackBarAction(label: 'Stop', onPressed: _stopAlarmSound),
                        duration: const Duration(seconds: 10),
                      ),
                    );
                  }
                }
              }
            });
          });
        } else {
          timer.timer?.cancel();
          timer.timer = null;
          _saveTimers(); // Save when timer is paused
        }
      }
    });
  }

  void _resetTimer(String id) {
    setState(() {
      final index = _timers.indexWhere((timer) => timer.id == id);
      if (index != -1) {
        final timer = _timers[index];
        timer.timer?.cancel();
        timer.timer = null;
        timer.isRunning = false;
        timer.remainingSeconds = timer.totalSeconds;

        // If this timer was completed and might be playing an alarm, stop it
        if (timer.remainingSeconds <= 0) {
          _stopAlarmSound();
          // Cancel any notifications for this timer
          final int notificationId = int.parse(id.substring(0, 8), radix: 16) % 100000;
          _notificationService.cancelNotification(notificationId);
        }
      }
    });
    _saveTimers(); // Save timers after resetting one
  }

  void _showAddTimerDialog() {
    final labelController = TextEditingController();
    int hours = 0;
    int minutes = 0;
    int seconds = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add New Timer',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: labelController,
                      decoration: InputDecoration(
                        labelText: 'Timer Label',
                        hintText: 'Enter a name for this timer',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: .3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // iOS-style wheel picker for time selection
                    TimeWheelPicker(
                      hours: hours,
                      minutes: minutes,
                      seconds: seconds,
                      onHoursChanged: (value) => setState(() => hours = value),
                      onMinutesChanged: (value) => setState(() => minutes = value),
                      onSecondsChanged: (value) => setState(() => seconds = value),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final label =
                              labelController.text.trim().isNotEmpty
                                  ? labelController.text.trim()
                                  : 'Timer ${_timers.length + 1}';
                          _addTimer(label, hours, minutes, seconds);
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Add Timer'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _timers.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 64,
                        color: colorScheme.primary.withValues(alpha: .5),
                      ),
                      const SizedBox(height: 16),
                      Text('No timers yet', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Add a timer by tapping the + button below',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: .7),
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _timers.length,
                  itemBuilder: (context, index) {
                    final timer = _timers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TimerCard(
                        timer: timer,
                        onDelete: _deleteTimer,
                        onToggle: _toggleTimer,
                        onReset: _resetTimer,
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTimerDialog,
        tooltip: 'Add Timer',
        child: const Icon(Icons.add),
      ),
    );
  }
}
