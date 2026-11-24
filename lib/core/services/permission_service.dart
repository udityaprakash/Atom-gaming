import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

class AlarmPermissionStatus {
  final bool notificationsGranted;
  final bool exactAlarmsGranted;
  final bool batteryOptimizationIgnored;

  const AlarmPermissionStatus({
    required this.notificationsGranted,
    required this.exactAlarmsGranted,
    required this.batteryOptimizationIgnored,
  });

  bool get allCriticalGranted =>
      notificationsGranted && exactAlarmsGranted && batteryOptimizationIgnored;

  AlarmPermissionStatus copyWith({
    bool? notificationsGranted,
    bool? exactAlarmsGranted,
    bool? batteryOptimizationIgnored,
  }) {
    return AlarmPermissionStatus(
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      exactAlarmsGranted: exactAlarmsGranted ?? this.exactAlarmsGranted,
      batteryOptimizationIgnored:
          batteryOptimizationIgnored ?? this.batteryOptimizationIgnored,
    );
  }
}

final permissionServiceProvider = Provider<PermissionService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PermissionService(db);
});

class PermissionService {
  final AppDatabase _db;
  static const MethodChannel _channel = MethodChannel('com.example.atom/permissions');
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String _onboardingKey = 'has_completed_permission_onboarding';

  PermissionService(this._db);

  /// Check all permissions required for reliable lock-screen and background alarms
  Future<AlarmPermissionStatus> checkAllPermissions() async {
    bool notifs = true;
    bool exact = true;
    bool battery = true;

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final androidPlatform = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlatform != null) {
          final enabled = await androidPlatform.areNotificationsEnabled();
          notifs = enabled ?? false;
        }
      } catch (_) {
        // Ignored in headless tests or uninitialized environments
      }

      try {
        final result = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
        exact = result ?? true;
      } catch (_) {
        // Ignored in unit test environment
      }

      try {
        final result = await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored');
        battery = result ?? true;
      } catch (_) {
        // Ignored in unit test environment
      }
    }

    return AlarmPermissionStatus(
      notificationsGranted: notifs,
      exactAlarmsGranted: exact,
      batteryOptimizationIgnored: battery,
    );
  }

  /// Request Notification permission (Android 13+)
  Future<bool> requestNotifications() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final androidPlatform = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlatform != null) {
          final granted = await androidPlatform.requestNotificationsPermission();
          return granted ?? false;
        }
      } catch (e) {
        debugPrint('Error requesting notifications: $e');
      }
    }
    return true;
  }

  /// Request Exact Alarms permission (Redirects to system Alarms & Reminders)
  Future<bool> requestExactAlarms() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _channel.invokeMethod<bool>('requestExactAlarmPermission');
        return result ?? false;
      } catch (e) {
        debugPrint('Error requesting exact alarm permission: $e');
      }
    }
    return true;
  }

  /// Request Ignore Battery Optimization (Unrestricted background usage)
  Future<bool> requestIgnoreBatteryOptimization() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _channel.invokeMethod<bool>('requestIgnoreBatteryOptimization');
        return result ?? false;
      } catch (e) {
        debugPrint('Error requesting battery optimization exemption: $e');
      }
    }
    return true;
  }

  /// Open App Settings details page
  Future<void> openAppSettings() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _channel.invokeMethod('openAppSettings');
      } catch (e) {
        debugPrint('Error opening app settings: $e');
      }
    }
  }

  /// Open App Notification Settings
  Future<void> openNotificationSettings() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _channel.invokeMethod('openNotificationSettings');
      } catch (e) {
        debugPrint('Error opening notification settings: $e');
      }
    }
  }

  /// Check whether the user has already acknowledged or dismissed onboarding
  Future<bool> hasCompletedOnboarding() async {
    final entry = await (_db.select(_db.appSettings)
          ..where((t) => t.key.equals(_onboardingKey)))
        .getSingleOrNull();
    return entry != null && entry.value == 'true';
  }

  /// Set onboarding completed
  Future<void> setCompletedOnboarding(bool completed) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _onboardingKey,
            value: completed.toString(),
            updatedAt: DateTime.now(),
          ),
        );
  }
}
