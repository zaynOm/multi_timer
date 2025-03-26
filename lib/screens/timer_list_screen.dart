import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/timer_data.dart';
import '../services/notification_service.dart';
import '../services/timer_storage_service.dart';
import '../widgets/time_selector.dart';
import '../widgets/timer_card.dart';

class TimerListScreen extends StatefulWidget {
  const TimerListScreen({super.key});

  @override
  State<TimerListScreen> createState() => _TimerListScreenState();
}

class _TimerListScreenState extends State<TimerListScreen> {
  final List<TimerData> _timers = [];
  final bool _soundEnabled = true;
  Timer? _alarmTimer;
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

  Future<void> _initNotifications() async {
    await _notificationService.initialize(
      onNotificationTap: (NotificationResponse response) {
        if (response.payload == 'stop_alarm') {
          _stopAlarmSound();
        }
      },
    );
  }

  @override
  void dispose() {
    // Cancel all active timers to prevent memory leaks
    for (var timer in _timers) {
      timer.timer?.cancel();
    }
    _alarmTimer?.cancel();
    super.dispose();
  }

  void _playAlarmSound() {
    if (_soundEnabled) {
      // Play system sound
      SystemSound.play(SystemSoundType.alert);
      // Add vibration for better notification
      HapticFeedback.vibrate();

      // Set up a repeating timer to play the alert sound multiple times
      _alarmTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.vibrate();
      });
    }
  }

  void _stopAlarmSound() {
    _alarmTimer?.cancel();
    _alarmTimer = null;
  }

  Future<void> _showNotification(String id, String timerLabel) async {
    final int notificationId =
        int.parse(id.substring(0, 8), radix: 16) % 100000;

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
    _saveTimers(); // Save timers after adding a new one
  }

  void _deleteTimer(String id) {
    setState(() {
      final index = _timers.indexWhere((timer) => timer.id == id);
      if (index != -1) {
        // If this is the timer that's currently playing an alarm, stop it
        if (_timers[index].remainingSeconds <= 0) {
          _stopAlarmSound();
          // Cancel any notifications for this timer
          final int notificationId =
              int.parse(id.substring(0, 8), radix: 16) % 100000;
          _notificationService.cancelNotification(notificationId);
        }
        _timers[index].timer?.cancel();
        _timers.removeAt(index);
      }
    });
    _saveTimers(); // Save timers after deleting one
  }

  void _toggleTimer(String id) {
    setState(() {
      final index = _timers.indexWhere((timer) => timer.id == id);
      if (index != -1) {
        final timer = _timers[index];
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
                  _saveTimers(); // Save when timer finishes

                  // Show in-app notification
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${timer.label} timer is complete!'),
                        action: SnackBarAction(
                          label: 'Stop',
                          onPressed: _stopAlarmSound,
                        ),
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
          final int notificationId =
              int.parse(id.substring(0, 8), radix: 16) % 100000;
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

    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add New Timer',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              surfaceTintColor: Colors.transparent,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration: InputDecoration(
                        labelText: 'Timer Label',
                        hintText: 'Enter a name for this timer',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Hours
                    TimeSelector(
                      label: 'Hours',
                      value: hours,
                      onDecrease:
                          hours > 0 ? () => setState(() => hours--) : null,
                      onIncrease: () => setState(() => hours++),
                    ),

                    // Minutes
                    TimeSelector(
                      label: 'Minutes',
                      value: minutes,
                      onDecrease:
                          minutes > 0 ? () => setState(() => minutes--) : null,
                      onIncrease:
                          minutes < 59 ? () => setState(() => minutes++) : null,
                    ),

                    // Seconds
                    TimeSelector(
                      label: 'Seconds',
                      value: seconds,
                      onDecrease:
                          seconds > 0 ? () => setState(() => seconds--) : null,
                      onIncrease:
                          seconds < 59 ? () => setState(() => seconds++) : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    final label =
                        labelController.text.trim().isNotEmpty
                            ? labelController.text.trim()
                            : 'Timer ${_timers.length + 1}';
                    _addTimer(label, hours, minutes, seconds);
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
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
      appBar: AppBar(
        title: const Text('Timers'),
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
      ),
      body:
          _timers.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 64,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No timers yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a timer by tapping the + button below',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTimerDialog,
        tooltip: 'Add Timer',
        child: const Icon(Icons.add),
      ),
    );
  }
}
