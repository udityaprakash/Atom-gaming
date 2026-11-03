import 'dart:async';
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

/// A 1-second interval ticker that updates all live UI timers
final liveTimerTickerProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
