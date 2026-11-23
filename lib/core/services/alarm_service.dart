import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vibration/vibration.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../router/app_router.dart';
import '../../features/sessions/data/session_repository.dart';
import '../../features/sessions/presentation/screens/alarm_trigger_screen.dart';

final alarmServiceProvider = Provider<AlarmService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final service = AlarmService(db);
  service.initialize();
  return service;
});

class AlarmSoundGenerator {
  static Future<File> getAlarmSoundFile() async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/atom_alarm_tone.wav');
    if (await file.exists() && await file.length() > 1000) {
      return file;
    }

    const sampleRate = 22050;
    const durationSeconds = 1.6;
    final totalSamples = (sampleRate * durationSeconds).toInt();
    final dataSize = totalSamples * 2; // 16-bit PCM = 2 bytes per sample

    final bytes = BytesBuilder();

    // 1. RIFF Header
    bytes.add(ascii.encode('RIFF'));
    final fileSize = 36 + dataSize;
    bytes.add(_int32ToBytes(fileSize));
    bytes.add(ascii.encode('WAVE'));

    // 2. fmt chunk
    bytes.add(ascii.encode('fmt '));
    bytes.add(_int32ToBytes(16)); // Chunk size 16 for PCM
    bytes.add(_int16ToBytes(1));  // AudioFormat 1 = PCM
    bytes.add(_int16ToBytes(1));  // Channels = 1 (Mono)
    bytes.add(_int32ToBytes(sampleRate)); // Sample rate
    bytes.add(_int32ToBytes(sampleRate * 2)); // Byte rate
    bytes.add(_int16ToBytes(2));  // Block align
    bytes.add(_int16ToBytes(16)); // Bits per sample

    // 3. data chunk
    bytes.add(ascii.encode('data'));
    bytes.add(_int32ToBytes(dataSize));

    // Synthesize two-tone digital alarm pattern (A5 880Hz & C6 1046Hz)
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      double sample = 0.0;

      if ((t >= 0.0 && t < 0.18) || (t >= 0.26 && t < 0.44)) {
        // High alert tone (880 Hz)
        sample = sin(2 * pi * 880 * t) * 0.95;
      } else if (t >= 0.52 && t < 0.80) {
        // Higher accent alert tone (1046.5 Hz)
        sample = sin(2 * pi * 1046.5 * t) * 0.98;
      }

      final intSample = (sample * 32767).toInt().clamp(-32768, 32767);
      bytes.add(_int16ToBytes(intSample));
    }

    await file.writeAsBytes(bytes.toBytes());
    return file;
  }

  static List<int> _int16ToBytes(int value) {
    return [value & 0xff, (value >> 8) & 0xff];
  }

  static List<int> _int32ToBytes(int value) {
    return [
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff,
    ];
  }
}

class AlarmService {
  final AppDatabase _db;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final StreamController<String> _alarmTriggerStreamController = StreamController<String>.broadcast();
  Stream<String> get onAlarmTriggered => _alarmTriggerStreamController.stream;

  bool _isInitialized = false;
  bool _isBuzzerActive = false;
  String? _currentlyDisplayingSessionId;

  bool get isBuzzerActive => _isBuzzerActive;

  static const String channelId = 'atom_session_alerts_v2';
  static const String channelName = 'atom Session Expiry Alarms';
  static const String channelDescription = 'Critical notifications and audible alarms when gaming sessions finish';

  AlarmService(this._db);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize native Alarm plugin
      try {
        await Alarm.init();

        // Listen to native Alarm ringing stream
        Alarm.ringing.listen((alarmSet) async {
          for (final alarmSettings in alarmSet.alarms) {
            debugPrint('Native Alarm ringing for ID: ${alarmSettings.id}, payload: ${alarmSettings.payload}');
            final sessionId = alarmSettings.payload;
            if (sessionId != null && sessionId.isNotEmpty) {
              _alarmTriggerStreamController.add(sessionId);
              await _handleSessionAlarmTrigger(sessionId);
            }
          }
        });
      } catch (alarmErr) {
        debugPrint('Alarm.init notice (unit test or mock mode): $alarmErr');
      }

      // 2. Initialize local notifications
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
          if (response.payload != null && response.payload!.isNotEmpty) {
            _alarmTriggerStreamController.add(response.payload!);
            _tryShowAlarmScreen(response.payload!);
          }
        },
      );

      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlatform != null) {
        // Create high-importance alarm notification channel
        final alarmChannel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 800, 400, 800, 400, 1000]),
        );
        await androidPlatform.createNotificationChannel(alarmChannel);

        // Request permissions for Android 13+ & Android 14+
        await androidPlatform.requestNotificationsPermission();
        await androidPlatform.requestExactAlarmsPermission();
      }

      // Pre-generate alarm sound file in background
      AlarmSoundGenerator.getAlarmSoundFile();

      _isInitialized = true;
    } catch (e) {
      debugPrint('AlarmService initialization error: $e');
    }
  }

  // --- Session Alarm Handler on Trigger ---
  Future<void> _handleSessionAlarmTrigger(String sessionId) async {
    try {
      // 1. If auto overtime is disabled, auto-pause session so timer doesn't accrue without consent
      final autoOvertime = await isAutoOvertimeEnabled();
      if (!autoOvertime) {
        final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
        if (session != null && session.status == AppConstants.sessionActive) {
          await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
            const SessionsCompanion(
              status: Value(AppConstants.sessionPaused),
            ),
          );
          await _db.into(_db.sessionEvents).insert(
            SessionEventsCompanion.insert(
              id: const Uuid().v4(),
              sessionId: sessionId,
              eventType: 'paused',
              eventTimestamp: DateTime.now(),
              notes: const Value('Auto-paused on timer expiration without Freeplay'),
            ),
          );
        }
      }

      // 2. Open alarm screen over keyguard/lockscreen if context available
      await _tryShowAlarmScreen(sessionId);
    } catch (e) {
      debugPrint('Error handling session alarm trigger: $e');
    }
  }

  Future<void> _tryShowAlarmScreen(String sessionId) async {
    if (_currentlyDisplayingSessionId == sessionId) return;

    try {
      final repo = SessionRepository(_db);
      final active = await repo.getActiveSessionById(sessionId);
      if (active == null) return;

      final navState = rootNavigatorKey.currentState;
      if (navState != null && navState.mounted) {
        _currentlyDisplayingSessionId = sessionId;
        navState.push(
          MaterialPageRoute(
            builder: (_) => AlarmTriggerScreen(activeSession: active),
            fullscreenDialog: true,
          ),
        ).then((_) {
          if (_currentlyDisplayingSessionId == sessionId) {
            _currentlyDisplayingSessionId = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error showing alarm screen: $e');
    }
  }

  // --- Persistent Settings Helpers ---
  Future<bool> isSoundEnabled() async {
    final entry = await (_db.select(_db.appSettings)..where((t) => t.key.equals('alarm_sound_enabled'))).getSingleOrNull();
    return entry == null || entry.value != 'false'; // Default true
  }

  Future<bool> isVibrationEnabled() async {
    final entry = await (_db.select(_db.appSettings)..where((t) => t.key.equals('alarm_vibration_enabled'))).getSingleOrNull();
    return entry == null || entry.value != 'false'; // Default true
  }

  Future<bool> isAutoOvertimeEnabled() async {
    final entry = await (_db.select(_db.appSettings)..where((t) => t.key.equals('auto_overtime_enabled'))).getSingleOrNull();
    return entry != null && entry.value == 'true'; // Default false: timer pauses on finish
  }

  Future<bool> isBillOnPauseEnabled() async {
    final entry = await (_db.select(_db.appSettings)..where((t) => t.key.equals('bill_on_pause_enabled'))).getSingleOrNull();
    return entry != null && entry.value == 'true'; // Default false: mid-session pause is free
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'alarm_sound_enabled',
            value: enabled.toString(),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'alarm_vibration_enabled',
            value: enabled.toString(),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> setAutoOvertimeEnabled(bool enabled) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'auto_overtime_enabled',
            value: enabled.toString(),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> setBillOnPauseEnabled(bool enabled) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'bill_on_pause_enabled',
            value: enabled.toString(),
            updatedAt: DateTime.now(),
          ),
        );
  }

  // --- Continuous Buzzer Fallback ---
  Future<void> startContinuousBuzzer() async {
    if (_isBuzzerActive) return;
    _isBuzzerActive = true;

    final soundOn = await isSoundEnabled();
    final vibrationOn = await isVibrationEnabled();

    // 1. Play looping alarm audio
    if (soundOn) {
      try {
        final soundFile = await AlarmSoundGenerator.getAlarmSoundFile();
        await _audioPlayer.stop();
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.play(DeviceFileSource(soundFile.path));
      } catch (e) {
        debugPrint('AudioPlayer error: $e');
      }
    }

    // 2. Play continuous repeating vibration pattern
    if (vibrationOn) {
      try {
        final hasVib = await Vibration.hasVibrator();
        if (hasVib == true) {
          await Vibration.vibrate(
            pattern: [0, 500, 250, 500, 250, 700, 300],
            repeat: 0,
          );
        }
      } catch (e) {
        debugPrint('Vibration error: $e');
      }
    }
  }

  Future<void> stopContinuousBuzzer() async {
    _isBuzzerActive = false;
    try {
      await _audioPlayer.stop();
    } catch (_) {}

    try {
      await Vibration.cancel();
    } catch (_) {}
  }

  // --- Testing Methods ---
  Future<void> testSound() async {
    try {
      final soundFile = await AlarmSoundGenerator.getAlarmSoundFile();
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(DeviceFileSource(soundFile.path));
    } catch (e) {
      debugPrint('Test sound error: $e');
    }
  }

  Future<void> testVibration() async {
    try {
      final hasVib = await Vibration.hasVibrator();
      if (hasVib == true) {
        await Vibration.vibrate(pattern: [0, 400, 200, 400, 200, 600]);
      }
    } catch (e) {
      debugPrint('Test vibration error: $e');
    }
  }

  Future<void> testNativeAlarm() async {
    try {
      final soundOn = await isSoundEnabled();
      final vibrationOn = await isVibrationEnabled();

      final alarmSettings = AlarmSettings(
        id: 999999,
        dateTime: DateTime.now().add(const Duration(seconds: 1)),
        assetAudioPath: 'assets/audio/alarm.mp3',
        loopAudio: true,
        vibrate: vibrationOn,
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        volumeSettings: VolumeSettings.fixed(
          volume: soundOn ? 1.0 : 0.0,
          volumeEnforced: true,
        ),
        notificationSettings: const NotificationSettings(
          title: "ATOM ALARM TEST",
          body: 'Native alarm and full screen intent test is ringing!',
          stopButton: 'Stop',
        ),
        payload: 'test_alert_preview',
      );

      await Alarm.set(alarmSettings: alarmSettings);
    } catch (e) {
      debugPrint('Error triggering test native alarm: $e');
    }
  }

  // --- Scheduled Native Alarms ---
  int _sessionIdToAlarmId(String sessionId) {
    return (sessionId.hashCode.abs() % 2000000000) + 1;
  }

  int _sessionIdToNotificationId(String sessionId) {
    return sessionId.hashCode.abs() % 100000;
  }

  Future<void> scheduleSessionAlert({
    required String sessionId,
    required String roomName,
    required DateTime scheduledEndAt,
  }) async {
    final now = DateTime.now();
    final soundOn = await isSoundEnabled();
    final vibrationOn = await isVibrationEnabled();
    final alarmId = _sessionIdToAlarmId(sessionId);

    // 1. Set Native Alarm via alarm plugin (wakes device, triggers fullScreenIntent)
    try {
      final alarmTime = scheduledEndAt.isBefore(now)
          ? now.add(const Duration(seconds: 1))
          : scheduledEndAt;

      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: alarmTime,
        assetAudioPath: 'assets/audio/alarm.mp3',
        loopAudio: true,
        vibrate: vibrationOn,
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        volumeSettings: VolumeSettings.fixed(
          volume: soundOn ? 1.0 : 0.0,
          volumeEnforced: true,
        ),
        notificationSettings: NotificationSettings(
          title: "TIME'S UP: $roomName",
          body: 'Gaming session duration has completed for $roomName!',
          stopButton: 'Stop',
        ),
        payload: sessionId,
      );

      await Alarm.set(alarmSettings: alarmSettings);
      debugPrint('Native Alarm set for session $sessionId at $alarmTime (Alarm ID: $alarmId)');
    } catch (e) {
      debugPrint('Error scheduling native alarm: $e');
    }

    // 2. Set backup local notification
    try {
      if (scheduledEndAt.isBefore(now)) {
        await showImmediateAlert(
          sessionId: sessionId,
          roomName: roomName,
          title: "TIME'S UP: $roomName",
          body: 'Gaming session duration has finished!',
        );
        return;
      }

      final notifId = _sessionIdToNotificationId(sessionId);
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
        id: notifId,
        title: "TIME'S UP: $roomName",
        body: 'Gaming session duration has completed for $roomName!',
        scheduledDate: tzScheduledTime,
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: sessionId,
      );
    } catch (e) {
      debugPrint('Error scheduling backup notification: $e');
    }
  }

  Future<void> showImmediateAlert({
    required String sessionId,
    required String roomName,
    required String title,
    required String body,
  }) async {
    final soundOn = await isSoundEnabled();
    final vibrationOn = await isVibrationEnabled();
    final alarmId = _sessionIdToAlarmId(sessionId);

    // 1. Trigger native alarm immediately (1s delay so AlarmManager executes instantly)
    try {
      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: DateTime.now().add(const Duration(seconds: 1)),
        assetAudioPath: 'assets/audio/alarm.mp3',
        loopAudio: true,
        vibrate: vibrationOn,
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        volumeSettings: VolumeSettings.fixed(
          volume: soundOn ? 1.0 : 0.0,
          volumeEnforced: true,
        ),
        notificationSettings: NotificationSettings(
          title: title,
          body: body,
          stopButton: 'Stop',
        ),
        payload: sessionId,
      );

      await Alarm.set(alarmSettings: alarmSettings);
    } catch (e) {
      debugPrint('Error triggering immediate native alarm: $e');
    }

    // 2. Immediate local notification fallback
    try {
      final notifId = _sessionIdToNotificationId(sessionId);
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 600, 300, 600, 300, 800]),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );

      await _notificationsPlugin.show(
        id: notifId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(android: androidDetails),
        payload: sessionId,
      );
    } catch (e) {
      debugPrint('Error showing immediate notification: $e');
    }
  }

  Future<void> cancelSessionAlert(String sessionId) async {
    try {
      final alarmId = _sessionIdToAlarmId(sessionId);
      await Alarm.stop(alarmId);
    } catch (e) {
      debugPrint('Error stopping native alarm on cancel: $e');
    }

    try {
      final notifId = _sessionIdToNotificationId(sessionId);
      await _notificationsPlugin.cancel(id: notifId);
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  Future<void> stopActiveAlarm([String? sessionId]) async {
    try {
      if (sessionId != null) {
        final alarmId = _sessionIdToAlarmId(sessionId);
        await Alarm.stop(alarmId);
        final notifId = _sessionIdToNotificationId(sessionId);
        await _notificationsPlugin.cancel(id: notifId);
      } else {
        await Alarm.stopAll();
        await _notificationsPlugin.cancelAll();
      }
    } catch (e) {
      debugPrint('Error stopping active alarm: $e');
    }

    await stopContinuousBuzzer();
  }
}
