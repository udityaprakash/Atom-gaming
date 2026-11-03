import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../database/app_database.dart';
import 'alarm_service.dart';

class RecoveryService {
  final AppDatabase _db;
  final AlarmService _alarmService;

  RecoveryService(this._db, this._alarmService);

  /// Scans database on startup and recovers all active sessions & alarms
  Future<void> recoverActiveSessions() async {
    try {
      final now = DateTime.now();

      // Query all uncompleted sessions (ACTIVE, OVERTIME, PAUSED)
      final uncompletedSessions = await (_db.select(_db.sessions)
            ..where((t) =>
                t.status.equals(AppConstants.sessionActive) |
                t.status.equals(AppConstants.sessionOvertime) |
                t.status.equals(AppConstants.sessionPaused)))
          .get();

      debugPrint('RecoveryService: Checking ${uncompletedSessions.length} active sessions');

      for (final session in uncompletedSessions) {
        // Find active segment and room
        final activeSegment = await (_db.select(_db.sessionSegments)
              ..where((t) => t.sessionId.equals(session.id) & t.endedAt.isNull()))
            .getSingleOrNull();

        if (activeSegment == null) continue;

        final room = await (_db.select(_db.rooms)..where((t) => t.id.equals(activeSegment.roomId))).getSingleOrNull();
        if (room == null) continue;

        if (session.status == AppConstants.sessionPaused) {
          // If paused, ensure room is in PAUSED state
          if (room.status != AppConstants.statusPaused) {
            await (_db.update(_db.rooms)..where((t) => t.id.equals(room.id))).write(
              RoomsCompanion(
                status: const Value(AppConstants.statusPaused),
                updatedAt: Value(now),
              ),
            );
          }
          continue;
        }

        // For ACTIVE sessions: check if expiration occurred while app/device was off
        if (now.isAfter(session.scheduledEndAt)) {
          // Flag session as OVERTIME
          await (_db.update(_db.sessions)..where((t) => t.id.equals(session.id))).write(
            const SessionsCompanion(status: Value(AppConstants.sessionOvertime)),
          );

          // Ensure room is OCCUPIED
          await (_db.update(_db.rooms)..where((t) => t.id.equals(room.id))).write(
            RoomsCompanion(
              status: const Value(AppConstants.statusOccupied),
              updatedAt: Value(now),
            ),
          );

          // Fire immediate overtime notification
          await _alarmService.showImmediateAlert(
            sessionId: session.id,
            roomName: room.roomName,
            title: 'SESSION OVERTIME: ${room.roomName}',
            body: 'Session ended during app restart/reboot. Overtime billing is continuing.',
          );
        } else {
          // Session is still within scheduled duration: reschedule exact alarm
          await _alarmService.scheduleSessionAlert(
            sessionId: session.id,
            roomName: room.roomName,
            scheduledEndAt: session.scheduledEndAt,
          );
        }
      }
    } catch (e) {
      debugPrint('RecoveryService error: $e');
    }
  }
}
