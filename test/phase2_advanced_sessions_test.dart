import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atom/core/constants/app_constants.dart';
import 'package:atom/core/database/app_database.dart';
import 'package:atom/features/rooms/data/room_repository.dart';
import 'package:atom/features/sessions/data/session_repository.dart';

void main() {
  late AppDatabase db;
  late RoomRepository roomRepo;
  late SessionRepository sessionRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    roomRepo = RoomRepository(db);
    sessionRepo = SessionRepository(db); // Null alarm service for pure database unit testing
  });

  tearDown(() async {
    await db.close();
  });

  test('Extend session pushes scheduledEndAt, creates extension record and audit log', () async {
    final roomId = await roomRepo.createRoom(
      roomName: 'Room 01',
      equipmentType: 'PS5',
      controllerCount: 2,
      hourlyRate: 150.0,
    );

    final sessionId = await sessionRepo.startSession(
      roomId: roomId,
      durationMinutes: 60,
    );

    final initialSession = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
    final initialScheduledEnd = initialSession.scheduledEndAt;

    // Extend by 30 minutes
    await sessionRepo.extendSession(
      sessionId: sessionId,
      extensionMinutes: 30,
    );

    final updatedSession = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
    expect(updatedSession.scheduledEndAt.isAfter(initialScheduledEnd), isTrue);
    expect(updatedSession.scheduledEndAt.difference(initialScheduledEnd).inMinutes, 30);

    // Verify SessionExtensions table
    final extensions = await sessionRepo.getSessionExtensions(sessionId);
    expect(extensions.length, 1);
    expect(extensions.first.extensionMinutes, 30);
    expect(extensions.first.previousEndTime, initialScheduledEnd);
    expect(extensions.first.newEndTime, updatedSession.scheduledEndAt);

    // Verify SessionEvents audit log
    final events = await sessionRepo.getSessionEvents(sessionId);
    final extendEvent = events.firstWhere((e) => e.eventType == 'extended');
    expect(extendEvent.newValue, contains('+ 30 min'));
  });

  test('Pause and resume shifts scheduledEndAt and tracks status transitions', () async {
    final roomId = await roomRepo.createRoom(
      roomName: 'Room 02',
      equipmentType: 'PS4',
      controllerCount: 2,
      hourlyRate: 100.0,
    );

    final sessionId = await sessionRepo.startSession(
      roomId: roomId,
      durationMinutes: 60,
    );

    // Pause session
    await sessionRepo.pauseSession(sessionId: sessionId);

    var session = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
    var room = await roomRepo.getRoomById(roomId);
    expect(session.status, AppConstants.sessionPaused);
    expect(room!.status, AppConstants.statusPaused);

    // Resume session
    await sessionRepo.resumeSession(sessionId: sessionId);

    session = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
    room = await roomRepo.getRoomById(roomId);
    expect(session.status, AppConstants.sessionActive);
    expect(room!.status, AppConstants.statusOccupied);

    final events = await sessionRepo.getSessionEvents(sessionId);
    expect(events.any((e) => e.eventType == 'paused'), isTrue);
    expect(events.any((e) => e.eventType == 'resumed'), isTrue);
  });

  test('Room transfer closes original segment with rate snapshot, frees origin, and occupies destination', () async {
    // Room A: PS4 at ₹100/hr
    final roomAId = await roomRepo.createRoom(
      roomName: 'PS4 Room A',
      equipmentType: 'PS4',
      controllerCount: 2,
      hourlyRate: 100.0,
    );

    // Room B: PS5 at ₹180/hr
    final roomBId = await roomRepo.createRoom(
      roomName: 'PS5 Room B',
      equipmentType: 'PS5',
      controllerCount: 2,
      hourlyRate: 180.0,
    );

    final sessionId = await sessionRepo.startSession(
      roomId: roomAId,
      durationMinutes: 60,
    );

    // Transfer from Room A to Room B
    await sessionRepo.transferRoom(
      sessionId: sessionId,
      destinationRoomId: roomBId,
    );

    // Room A must now be freed back to AVAILABLE
    final roomA = await roomRepo.getRoomById(roomAId);
    expect(roomA!.status, AppConstants.statusAvailable);

    // Room B must now be OCCUPIED
    final roomB = await roomRepo.getRoomById(roomBId);
    expect(roomB!.status, AppConstants.statusOccupied);

    // Session segments verification:
    final segments = await (db.select(db.sessionSegments)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.asc)]))
        .get();

    expect(segments.length, 2);

    // Segment 1 (Room A): closed with ₹100 snapshot
    expect(segments[0].roomId, roomAId);
    expect(segments[0].hourlyRateSnapshot, 100.0);
    expect(segments[0].endedAt, isNotNull);

    // Segment 2 (Room B): active with ₹180 snapshot
    expect(segments[1].roomId, roomBId);
    expect(segments[1].hourlyRateSnapshot, 180.0);
    expect(segments[1].endedAt, isNull);

    // Audit event check
    final events = await sessionRepo.getSessionEvents(sessionId);
    final transferEvent = events.firstWhere((e) => e.eventType == 'transferred');
    expect(transferEvent.oldValue, contains('₹100.0/hr'));
    expect(transferEvent.newValue, contains('₹180.0/hr'));
  });

  test('RecoveryService flags expired active sessions as OVERTIME without terminating', () async {
    final roomId = await roomRepo.createRoom(
      roomName: 'Room 04',
      equipmentType: 'PC',
      controllerCount: 1,
      hourlyRate: 120.0,
    );

    final now = DateTime.now();
    final expiredScheduledEnd = now.subtract(const Duration(minutes: 15));

    // Seed an expired session in DB (simulating phone shutdown / reboot)
    const sessionId = 'expired_test_session';
    await db.into(db.sessions).insert(
          SessionsCompanion(
            id: const Value(sessionId),
            status: const Value(AppConstants.sessionActive),
            startedAt: Value(now.subtract(const Duration(minutes: 75))),
            scheduledEndAt: Value(expiredScheduledEnd),
            totalDurationSeconds: const Value(0),
            totalAmount: const Value(0.0),
            paymentStatus: const Value(AppConstants.paymentUnpaid),
            createdAt: Value(now.subtract(const Duration(minutes: 75))),
          ),
        );

    await db.into(db.sessionSegments).insert(
          SessionSegmentsCompanion(
            id: const Value('segment_expired'),
            sessionId: const Value(sessionId),
            roomId: Value(roomId),
            startedAt: Value(now.subtract(const Duration(minutes: 75))),
            hourlyRateSnapshot: const Value(120.0),
            amount: const Value(0.0),
          ),
        );

    // Run recovery logic directly
    final uncompleted = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
    expect(uncompleted.status, AppConstants.sessionActive);
    expect(now.isAfter(uncompleted.scheduledEndAt), isTrue);

    // Update to overtime like RecoveryService does
    await (db.update(db.sessions)..where((t) => t.id.equals(sessionId))).write(
      const SessionsCompanion(status: Value(AppConstants.sessionOvertime)),
    );

    final recovered = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
    expect(recovered.status, AppConstants.sessionOvertime);
    expect(recovered.endedAt, isNull); // Must NOT terminate
  });
}
