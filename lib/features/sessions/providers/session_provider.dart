import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/services/alarm_service.dart';
import '../data/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final alarmService = ref.watch(alarmServiceProvider);
  return SessionRepository(db, alarmService);
});

final activeRoomSessionsStreamProvider = StreamProvider<List<ActiveRoomSession>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchActiveRoomSessions();
});

final activeRoomSessionsMapProvider = Provider<Map<String, ActiveRoomSession>>((ref) {
  final sessionsAsync = ref.watch(activeRoomSessionsStreamProvider);
  return sessionsAsync.maybeWhen(
    data: (sessions) => {for (var s in sessions) s.room.id: s},
    orElse: () => {},
  );
});

final dashboardStatsStreamProvider = StreamProvider<DashboardStats>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchDashboardStats();
});

final unpaidSessionsStreamProvider = StreamProvider<List<UnpaidSessionItem>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchUnpaidSessions();
});

// Session History Notifiers
class SessionHistoryDatePresetNotifier extends Notifier<String> {
  @override
  String build() => 'ALL';
  void setPreset(String val) => state = val;
}

final sessionHistoryDatePresetProvider =
    NotifierProvider<SessionHistoryDatePresetNotifier, String>(SessionHistoryDatePresetNotifier.new);

class SessionHistoryCustomRangeNotifier extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;
  void setRange(DateTimeRange? val) => state = val;
}

final sessionHistoryCustomRangeProvider =
    NotifierProvider<SessionHistoryCustomRangeNotifier, DateTimeRange?>(SessionHistoryCustomRangeNotifier.new);

class SessionHistoryPaymentStatusNotifier extends Notifier<String> {
  @override
  String build() => 'ALL';
  void setStatus(String val) => state = val;
}

final sessionHistoryPaymentStatusProvider =
    NotifierProvider<SessionHistoryPaymentStatusNotifier, String>(SessionHistoryPaymentStatusNotifier.new);

class SessionHistoryRoomIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setRoomId(String? val) => state = val;
}

final sessionHistoryRoomIdProvider =
    NotifierProvider<SessionHistoryRoomIdNotifier, String?>(SessionHistoryRoomIdNotifier.new);

class SessionHistorySearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String val) => state = val;
}

final sessionHistorySearchQueryProvider =
    NotifierProvider<SessionHistorySearchQueryNotifier, String>(SessionHistorySearchQueryNotifier.new);

final sessionHistoryStreamProvider = StreamProvider<List<HistoricalSessionItem>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  final preset = ref.watch(sessionHistoryDatePresetProvider);
  final customRange = ref.watch(sessionHistoryCustomRangeProvider);
  final paymentStatus = ref.watch(sessionHistoryPaymentStatusProvider);
  final roomId = ref.watch(sessionHistoryRoomIdProvider);
  final query = ref.watch(sessionHistorySearchQueryProvider);

  DateTime? startDate;
  DateTime? endDate;

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

  switch (preset) {
    case 'TODAY':
      startDate = todayStart;
      endDate = todayEnd;
      break;
    case 'YESTERDAY':
      final yesterday = now.subtract(const Duration(days: 1));
      startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
      endDate = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
      break;
    case 'THIS_WEEK':
      final monday = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(monday.year, monday.month, monday.day);
      endDate = todayEnd;
      break;
    case 'THIS_MONTH':
      startDate = DateTime(now.year, now.month, 1);
      endDate = todayEnd;
      break;
    case 'CUSTOM':
      if (customRange != null) {
        startDate = DateTime(customRange.start.year, customRange.start.month, customRange.start.day);
        endDate = DateTime(customRange.end.year, customRange.end.month, customRange.end.day, 23, 59, 59);
      }
      break;
    case 'ALL':
    default:
      startDate = null;
      endDate = null;
      break;
  }

  return repo.watchSessionHistory(
    startDate: startDate,
    endDate: endDate,
    paymentStatus: paymentStatus,
    roomId: roomId,
    searchQuery: query,
  );
});

final sessionTimelineFamilyProvider = FutureProvider.family<DetailedSessionTimeline, String>((ref, sessionId) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getSessionTimeline(sessionId);
});

/// A 1-second interval ticker that updates all live UI timers
final liveTimerTickerProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
