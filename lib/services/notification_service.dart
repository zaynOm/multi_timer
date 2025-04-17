import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

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
      playSound: false,
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
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == 'stop_alarm' || response.actionId == stopSoundAction) {
      if (_onStopAlarmCallback != null) {
        _onStopAlarmCallback!();
      }
    }
  }

  Function? _onStopAlarmCallback;
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
      category: AndroidNotificationCategory.alarm,
      actions: [AndroidNotificationAction(stopSoundAction, 'Silence')],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, notificationDetails, payload: payload);
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
