import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Background FCM message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] title: ${message.notification?.title}');
}

/// Centralized Notification Service for the EXIF Forensics App.
///
/// Handles:
/// - Local instant notifications
/// - Scheduled (timezone-aware) notifications
/// - Firebase Cloud Messaging (push) notifications
/// - Notification click / tap actions
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // ─── Plugin & Channel constants ────────────────────────────────────────────

  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId    = 'exif_forensics_channel';
  static const String _channelName  = 'EXIF Forensics Alerts';
  static const String _channelDesc  =
      'Notifications for EXIF analysis, reminders, and forensic alerts.';

  // Callback invoked when user taps a notification (passes payload string)
  void Function(String? payload)? onNotificationTap;

  // ─── Initialization ────────────────────────────────────────────────────────

  /// Call once from main() after Firebase.initializeApp()
  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    await _initLocalNotifications();
    await _initFCM();
  }

  // ── Local Notifications ───────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('[LocalNotif] tapped — payload: ${response.payload}');
        onNotificationTap?.call(response.payload);
      },
    );

    // Request Android 13+ notification permission
    if (Platform.isAndroid) {
      await _localPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Create the notification channel (Android 8+)
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
      );
      await _localPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    debugPrint('[NotificationService] Local notifications initialized.');
  }

  // ── FCM Push Notifications ────────────────────────────────────────────────

  Future<void> _initFCM() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission (iOS + Android 13+)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // Get FCM token (useful for targeted server pushes)
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('[FCM] Device token: $token');

    // Foreground message: show as local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM Foreground] ${message.notification?.title}');
      final notif = message.notification;
      if (notif != null) {
        showInstantNotification(
          title: notif.title ?? 'New Alert',
          body: notif.body ?? '',
          payload: message.data['screen'],
        );
      }
    });

    // Notification tap when app is in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Notification opened from background');
      onNotificationTap?.call(message.data['screen']);
    });

    // Notification tap when app was terminated
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] App opened from terminated state via notification');
      onNotificationTap?.call(initial.data['screen']);
    }

    debugPrint('[NotificationService] FCM initialized.');
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Show an instant local notification.
  Future<void> showInstantNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localPlugin.show(id, title, body, details, payload: payload);
    debugPrint('[NotificationService] Instant notification shown: "$title"');
  }

  /// Schedule a notification at a future [scheduledTime].
  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localPlugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('[NotificationService] Scheduled notification at $scheduledTime');
  }

  /// Schedule a daily repeating notification at [hour]:[minute].
  Future<void> scheduleDailyNotification({
    int id = 2,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );

    debugPrint('[NotificationService] Daily notification set for $hour:$minute');
  }

  /// Cancel a specific notification by [id].
  Future<void> cancelNotification(int id) async {
    await _localPlugin.cancel(id);
    debugPrint('[NotificationService] Cancelled notification id=$id');
  }

  /// Cancel ALL notifications.
  Future<void> cancelAll() async {
    await _localPlugin.cancelAll();
    debugPrint('[NotificationService] All notifications cancelled.');
  }
}
