import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:multi_timer/providers/settings_provider.dart';
import 'package:timezone/timezone.dart' as tz;

const String stopSoundAction = 'stop_sound_action';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.actionId == stopSoundAction) {
    final SendPort? sendPort = IsolateNameServer.lookupPortByName('alarm_stop_port');
    if (sendPort != null) {
      sendPort.send('stop_alarm');
    }
    FlutterLocalNotificationsPlugin().cancel(notificationResponse.id ?? 0);
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  // ignore: unused_field
  final SettingsProvider _settingsProvider;
  bool _initialized = false;
  Function? _onStopAlarmCallback;

  NotificationService(this._settingsProvider);

  Future<void> initialize() async {
    if (_initialized) return;

    // Set up isolate communication for background notifications
    final receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'alarm_stop_port');

    // Listen for messages from background isolate
    receivePort.listen((message) {
      if (message == 'stop_alarm' && _onStopAlarmCallback != null) {
        _onStopAlarmCallback!();
      }
    });

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'timer_alarm_channel',
      'Timer Alarms',
      description: 'Notifications for timer alarms',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const androidSettings = AndroidInitializationSettings('ic_stat_notification');

    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _setupNotificationActions();
    _initialized = true;
  }

  Future<void> _setupNotificationActions() async {
    // Request notification permission for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == 'stop_alarm' || response.actionId == stopSoundAction) {
      if (_onStopAlarmCallback != null) {
        _onStopAlarmCallback!();
      }
    }
  }

  void setOnStopAlarmCallback(Function callback) {
    _onStopAlarmCallback = callback;
  }

  Future<void> showTimerNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    final androidDetails = const AndroidNotificationDetails(
      'timer_channel',
      'Timer Notifications',
      channelDescription: 'Notifications for completed timers',
      color: Color(0xFF549ee1),
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      // enableVibration: _settingsProvider.isVibrationEnabled,
      category: AndroidNotificationCategory.alarm,
      actions: [AndroidNotificationAction(stopSoundAction, 'Silence')],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, notificationDetails, payload: payload);
  }

  Future<void> scheduleTimerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    // Ensure the scheduledDateTime is in the future
    if (scheduledDateTime.isBefore(DateTime.now())) {
      // Optionally handle this case, e.g., show immediately or log an error
      // For now, we'll just show it immediately if it's in the past
      await showTimerNotification(id: id, title: title, body: body, payload: payload);
      return;
    }

    final androidDetails = const AndroidNotificationDetails(
      'timer_alarm_channel', // Use the same channel as initialized
      'Timer Alarms',
      channelDescription: 'Notifications for timer alarms',
      color: Color(0xFF549ee1),
      importance: Importance.max,
      priority: Priority.high,
      playSound: true, // Ensure sound is enabled for scheduled notifications
      sound: RawResourceAndroidNotificationSound('alarm_sound'), // Match channel sound
      // enableVibration: _settingsProvider.isVibrationEnabled, // Consider settings
      category: AndroidNotificationCategory.alarm,
      actions: [AndroidNotificationAction(stopSoundAction, 'Silence')],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
