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
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Initialize the notification service
  Future<void> initialize({
    Function(NotificationResponse)? onNotificationTap,
    Function? stopSoundCallback,
  }) async {
    if (_isInitialized) return;

    // Set up isolate communication for background notifications
    final receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'alarm_stop_port');

    // Listen for messages from background isolate
    receivePort.listen((message) {
      if (message == 'stop_alarm' && stopSoundCallback != null) {
        stopSoundCallback();
      }
    });

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'timer_alarm_channel',
      'Timer Alarms',
      description: 'Notifications for timer alarms',
      importance: Importance.max,
      enableVibration: true,
      playSound: false,
      showBadge: true,
    );

    // Request notification permissions
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Create the notification channel
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize notification settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    // Initialize with callbacks
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _isInitialized = true;
  }

  // Show a notification for a completed timer
  Future<void> showTimerNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    if (!_isInitialized) return;

    final List<AndroidNotificationAction> actions = [
      const AndroidNotificationAction(
        stopSoundAction,
        'Stop',
        showsUserInterface: false,
        cancelNotification: true,
      ),
    ];

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'timer_alarm_channel',
      'Timer Alarms',
      channelDescription: 'Notifications for timer alarms',
      importance: Importance.high,
      priority: Priority.high,
      actions: actions,
      playSound: false,
      ongoing: true,
      category: AndroidNotificationCategory.alarm,
    );

    final NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
