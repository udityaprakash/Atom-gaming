import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class AlarmService {
  final AppDatabase _db;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final StreamController<String> _alarmTriggerStreamController = StreamController<String>.broadcast();
  Stream<String> get onAlarmTriggered => _alarmTriggerStreamController.stream;

  bool _isInitialized = false;
  bool _isBuzzerActive = false;
  bool _isAlarmScreenActive = false;
  String? _currentlyDisplayingSessionId;
  int? _activeAudioAlarmId;

  Future<bool> isRingingActive() async {
    if (_activeAudioAlarmId == null) return false;
    try {
      return await Alarm.isRinging(_activeAudioAlarmId!);
    } catch (_) {
      return false;
    }
  }

  // Track sessions whose alarm has been dismissed or acted upon to prevent duplicate triggers
  final Set<String> _dismissedSessionIds = <String>{};

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
              final alarmId = alarmSettings.id;
              final isAlreadyRinging = await isRingingActive();

              if (isAlreadyRinging && _activeAudioAlarmId != alarmId) {
                // An alarm sound is ALREADY ringing! Loosely decouple:
                // Stop this second alarm's audio immediately in native Android to prevent overlapping sound.
                try {
                  await Alarm.stop(alarmId);
                } catch (_) {}
                debugPrint('Suppressed duplicate audio for alarm $alarmId (Session $sessionId). Audio from $_activeAudioAlarmId is already playing.');
              } else if (!isAlreadyRinging) {
                _activeAudioAlarmId = alarmId;
              }

              _alarmTriggerStreamController.add(sessionId);
              await _handleSessionAlarmTrigger(sessionId);
            }
          }
        });
      } catch (alarmErr) {
        debugPrint('Alarm.init notice (unit test or mock mode): $alarmErr');
      }

      // 2. Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(
        settings: initSettings,
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
      }

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

  final List<String> _pendingAlarmQueue = <String>[];

  List<String> get pendingAlarmQueue => List.unmodifiable(_pendingAlarmQueue);
  int get pendingAlarmCount => _pendingAlarmQueue.length;

  Future<void> _tryShowAlarmScreen(String sessionId) async {
    // If dismissed, already showing, or already queued, do not re-trigger
    if (_dismissedSessionIds.contains(sessionId) ||
        _currentlyDisplayingSessionId == sessionId ||
        _pendingAlarmQueue.contains(sessionId)) {
      return;
    }

    // If an alarm screen is currently active on screen, queue this session
    if (_isAlarmScreenActive) {
      if (!_pendingAlarmQueue.contains(sessionId)) {
        _pendingAlarmQueue.add(sessionId);
      }
      _alarmTriggerStreamController.add(sessionId);
      debugPrint('Queued alarm screen for session $sessionId. Pending queue size: ${_pendingAlarmQueue.length}');
      return;
    }

    await _presentAlarmScreen(sessionId);
  }

  Future<void> _presentAlarmScreen(String sessionId) async {
    if (_dismissedSessionIds.contains(sessionId)) {
      _checkAndShowNextPendingAlarm();
      return;
    }

    // Set currently displaying session immediately to lock against concurrent triggers
    _currentlyDisplayingSessionId = sessionId;

    try {
      final repo = SessionRepository(_db);
      final active = await repo.getActiveSessionById(sessionId);
      if (active == null ||
          active.session.status == AppConstants.sessionCompleted ||
          _dismissedSessionIds.contains(sessionId)) {
        if (_currentlyDisplayingSessionId == sessionId) {
          _currentlyDisplayingSessionId = null;
        }
        _checkAndShowNextPendingAlarm();
        return;
      }

      final navState = rootNavigatorKey.currentState;
      if (navState != null && navState.mounted) {
        _isAlarmScreenActive = true;

        navState.push(
          MaterialPageRoute(
            builder: (_) => AlarmTriggerScreen(
              activeSession: active,
              pendingQueueCount: _pendingAlarmQueue.length,
            ),
            fullscreenDialog: true,
          ),
        ).then((_) {
          _isAlarmScreenActive = false;
          if (_currentlyDisplayingSessionId == sessionId) {
            _currentlyDisplayingSessionId = null;
          }
          // When current alarm screen is closed, present the next pending expired room
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndShowNextPendingAlarm();
          });
        });
      } else {
        _isAlarmScreenActive = false;
        if (_currentlyDisplayingSessionId == sessionId) {
          _currentlyDisplayingSessionId = null;
        }
        if (!_pendingAlarmQueue.contains(sessionId) && !_dismissedSessionIds.contains(sessionId)) {
          _pendingAlarmQueue.add(sessionId);
        }
      }
    } catch (e) {
      _isAlarmScreenActive = false;
      if (_currentlyDisplayingSessionId == sessionId) {
        _currentlyDisplayingSessionId = null;
      }
      debugPrint('Error showing alarm screen: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowNextPendingAlarm();
      });
    }
  }

  void _checkAndShowNextPendingAlarm() {
    if (_isAlarmScreenActive) return;

    while (_pendingAlarmQueue.isNotEmpty) {
      final nextSessionId = _pendingAlarmQueue.removeAt(0);
      if (!_dismissedSessionIds.contains(nextSessionId) && nextSessionId != _currentlyDisplayingSessionId) {
        _presentAlarmScreen(nextSessionId);
        return;
      }
    }
  }

  bool _isCheckingPending = false;

  /// Checks for any active sessions whose scheduled time has passed or native alarms currently ringing,
  /// and presents the AlarmTriggerScreen immediately if the app is in foreground.
  Future<void> checkAndPresentPendingAlarms() async {
    if (!_isInitialized || _isCheckingPending) return;
    final navState = rootNavigatorKey.currentState;
    if (navState == null || !navState.mounted) return;
    if (_isAlarmScreenActive) return;

    _isCheckingPending = true;

    // 1. Check ringing alarms reported by native Alarm plugin
    try {
      final ringingAlarms = await Alarm.getAlarms();
      for (final alarm in ringingAlarms) {
        final isRinging = await Alarm.isRinging(alarm.id);
        if (isRinging) {
          final sId = alarm.payload;
          if (sId != null &&
              sId.isNotEmpty &&
              !_dismissedSessionIds.contains(sId) &&
              !_pendingAlarmQueue.contains(sId) &&
              sId != _currentlyDisplayingSessionId) {
            _pendingAlarmQueue.add(sId);
          }

          // Ensure single active audio source: keep only the first, silence duplicate audio
          if (_activeAudioAlarmId == null) {
            _activeAudioAlarmId = alarm.id;
          } else if (_activeAudioAlarmId != alarm.id) {
            try {
              await Alarm.stop(alarm.id);
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      debugPrint('Notice checking native ringing alarms: $e');
    }

    // 2. Check active expired sessions in database
    try {
      final now = DateTime.now();
      final uncompleted = await (_db.select(_db.sessions)
            ..where((t) => t.status.isIn([
                  AppConstants.sessionActive,
                  AppConstants.sessionPaused,
                  AppConstants.sessionOvertime,
                ])))
          .get();

      for (final session in uncompleted) {
        if (now.isAfter(session.scheduledEndAt) &&
            session.billingPolicy != 'freeplay' &&
            !_dismissedSessionIds.contains(session.id) &&
            !_pendingAlarmQueue.contains(session.id) &&
            session.id != _currentlyDisplayingSessionId) {
          _pendingAlarmQueue.add(session.id);
        }
      }
    } catch (e) {
      debugPrint('Notice checking database expired sessions: $e');
    } finally {
      _isCheckingPending = false;
    }

    // 3. Present next pending alarm
    _checkAndShowNextPendingAlarm();
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

  // --- Continuous Buzzer (Audio is managed strictly by native Alarm plugin) ---
  Future<void> startContinuousBuzzer() async {}

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
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('audio/alarm.mp3'));
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
        allowAlarmOverlap: true,
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

  Future<void> scheduleSessionAlert({
    required String sessionId,
    required String roomName,
    required DateTime scheduledEndAt,
  }) async {
    _dismissedSessionIds.remove(sessionId);
    final now = DateTime.now();
    final soundOn = await isSoundEnabled();
    final vibrationOn = await isVibrationEnabled();
    final alarmId = _sessionIdToAlarmId(sessionId);

    // Single source of truth: Set Native Alarm via alarm plugin (wakes device, triggers fullScreenIntent)
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
        allowAlarmOverlap: true,
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

    // Single source of truth: Trigger native alarm immediately
    try {
      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: DateTime.now().add(const Duration(seconds: 1)),
        assetAudioPath: 'assets/audio/alarm.mp3',
        loopAudio: true,
        vibrate: vibrationOn,
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        allowAlarmOverlap: true,
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
  }

  Future<void> cancelSessionAlert(String sessionId) async {
    try {
      final alarmId = _sessionIdToAlarmId(sessionId);
      await Alarm.stop(alarmId);
    } catch (e) {
      debugPrint('Error stopping native alarm on cancel: $e');
    }
  }

  Future<void> stopActiveAlarm([String? sessionId, bool silenceSound = false]) async {
    if (sessionId != null) {
      _dismissedSessionIds.add(sessionId);
      _pendingAlarmQueue.remove(sessionId);
    } else {
      _isAlarmScreenActive = false;
      _currentlyDisplayingSessionId = null;
      _pendingAlarmQueue.clear();
    }

    // Loosely coupled sound control:
    // If user explicitly asked to silence sound, or if all queued/pending alarms are clear, stop all ringing.
    final hasPending = _pendingAlarmQueue.isNotEmpty;
    if (silenceSound || !hasPending) {
      _activeAudioAlarmId = null;
      try {
        await Alarm.stopAll();
      } catch (e) {
        debugPrint('Error stopping native alarms on dismiss: $e');
      }
      await stopContinuousBuzzer();
    }
  }
}
