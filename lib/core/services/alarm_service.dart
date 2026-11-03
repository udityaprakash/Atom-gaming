import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vibration/vibration.dart';

final alarmServiceProvider = Provider<AlarmService>((ref) {
  final service = AlarmService();
  service.initialize();
  return service;
});

class AlarmService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String channelId = 'atom_session_alerts';
  static const String channelName = 'atom Session Alerts';
  static const String channelDescription =
      'Alarms and notifications when gaming room sessions end';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // Request notification permissions for Android 13+
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.requestNotificationsPermission();
        await androidPlatform.requestExactAlarmsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('AlarmService initialization error: $e');
    }
  }

  int _sessionIdToNotificationId(String sessionId) {
    return sessionId.hashCode.abs() % 100000;
  }

  Future<void> scheduleSessionAlert({
    required String sessionId,
    required String roomName,
    required DateTime scheduledEndAt,
  }) async {
    try {
      final now = DateTime.now();
      if (scheduledEndAt.isBefore(now)) {
        // Already ended or overtime, trigger immediate reminder notification
        await showImmediateAlert(
          sessionId: sessionId,
          roomName: roomName,
          title: 'SESSION EXPIRED: $roomName',
          body: 'Session time has ended! Overtime billing is now active.',
        );
        return;
      }

      final id = _sessionIdToNotificationId(sessionId);
      final tzScheduledTime = tz.TZDateTime.from(scheduledEndAt, tz.local);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 800, 400, 800, 400, 1000]),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        actions: const [
          AndroidNotificationAction('extend', 'Extend'),
          AndroidNotificationAction('end', 'End Session'),
        ],
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'TIME UP: $roomName',
        body: 'Gaming session for $roomName has completed scheduled duration.',
        scheduledDate: tzScheduledTime,
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: sessionId,
      );
    } catch (e) {
      debugPrint('Error scheduling session alert: $e');
    }
  }

  Future<void> showImmediateAlert({
    required String sessionId,
    required String roomName,
    required String title,
    required String body,
  }) async {
    try {
      final id = _sessionIdToNotificationId(sessionId);
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 600, 300, 600]),
      );

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(android: androidDetails),
        payload: sessionId,
      );
    } catch (e) {
      debugPrint('Error showing immediate alert: $e');
    }
  }

  Future<void> cancelSessionAlert(String sessionId) async {
    try {
      final id = _sessionIdToNotificationId(sessionId);
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Error cancelling session alert: $e');
    }
  }

  Future<void> triggerVibrationPattern([List<int>? pattern]) async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        if (pattern != null) {
          await Vibration.vibrate(pattern: pattern);
        } else {
          await Vibration.vibrate(pattern: [0, 500, 200, 500]);
        }
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }
}
