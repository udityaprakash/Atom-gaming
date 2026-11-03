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
    sessionRepo = SessionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Start session transitions room to OCCUPIED and creates segment snapshot', () async {
    final roomId = await roomRepo.createRoom(
      roomName: 'Room 01',
      equipmentType: 'PS5',
      controllerCount: 2,
      hourlyRate: 150.0,
    );

    final sessionId = await sessionRepo.startSession(
      roomId: roomId,
      durationMinutes: 60,
      customerName: 'Aman Kumar',
      customerPhone: '9876543210',
    );

    expect(sessionId, isNotEmpty);

    // Verify room status changed to OCCUPIED
    final room = await roomRepo.getRoomById(roomId);
    expect(room!.status, AppConstants.statusOccupied);

    // Verify session in database
    final session = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
    expect(session.status, AppConstants.sessionActive);
    expect(session.paymentStatus, AppConstants.paymentUnpaid);

    // Verify segment price snapshot
    final segment = await (db.select(db.sessionSegments)..where((t) => t.sessionId.equals(sessionId))).getSingle();
    expect(segment.roomId, roomId);
    expect(segment.hourlyRateSnapshot, 150.0);
    expect(segment.endedAt, isNull);
  });

  test('Throws exception if starting session on an already occupied room', () async {
    final roomId = await roomRepo.createRoom(
      roomName: 'Room 02',
      equipmentType: 'PS4',
      controllerCount: 2,
      hourlyRate: 100.0,
    );

    await sessionRepo.startSession(
      roomId: roomId,
      durationMinutes: 30,
    );

    // Attempting to start another session on the same room must fail
    expect(
      () => sessionRepo.startSession(roomId: roomId, durationMinutes: 60),
      throwsA(isA<Exception>()),
    );
  });

  test('Safeguard prevents deleting room if historical session segments exist', () async {
    final roomId = await roomRepo.createRoom(
      roomName: 'Protected Room',
      equipmentType: 'PC',
      controllerCount: 1,
      hourlyRate: 120.0,
    );

    final sessionId = await sessionRepo.startSession(
      roomId: roomId,
      durationMinutes: 30,
    );

    // Cannot delete active room
    final deletedActive = await roomRepo.deleteRoom(roomId);
    expect(deletedActive, isFalse);

    // End session
    await sessionRepo.endSession(sessionId: sessionId, paymentStatus: AppConstants.paymentPaid);

    // Still cannot delete because historical sessions exist
    final deletedHistory = await roomRepo.deleteRoom(roomId);
    expect(deletedHistory, isFalse);
  });

  test('End session marks PAID, records cash collected and frees room', () async {
    final roomId = await roomRepo.createRoom(
      roomName: 'Room 03',
      equipmentType: 'PS5',
      controllerCount: 2,
      hourlyRate: 180.0,
    );

    final sessionId = await sessionRepo.startSession(
      roomId: roomId,
      durationMinutes: 60,
    );

    await sessionRepo.endSession(
      sessionId: sessionId,
      paymentStatus: AppConstants.paymentPaid,
    );

    // Room must be freed back to AVAILABLE
    final room = await roomRepo.getRoomById(roomId);
    expect(room!.status, AppConstants.statusAvailable);

    // Session completed
    final session = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
    expect(session.status, AppConstants.sessionCompleted);
    expect(session.paymentStatus, AppConstants.paymentPaid);
    expect(session.endedAt, isNotNull);

    // Payment record created with CASH
    final payment = await (db.select(db.payments)..where((t) => t.sessionId.equals(sessionId))).getSingle();
    expect(payment.paymentMethod, AppConstants.methodCash);
    expect(payment.paymentStatus, AppConstants.paymentPaid);
    expect(payment.paidAt, isNotNull);
  });

  test('End session marks UNPAID records outstanding debt', () async {
    final roomId = await roomRepo.createRoom(
      roomName: 'Room 04',
      equipmentType: 'PS4',
      controllerCount: 2,
      hourlyRate: 100.0,
    );

    final sessionId = await sessionRepo.startSession(
      roomId: roomId,
      durationMinutes: 60,
    );

    await sessionRepo.endSession(
      sessionId: sessionId,
      paymentStatus: AppConstants.paymentUnpaid,
    );

    final payment = await (db.select(db.payments)..where((t) => t.sessionId.equals(sessionId))).getSingle();
    expect(payment.paymentStatus, AppConstants.paymentUnpaid);
    expect(payment.amountCollected, 0.0);
    expect(payment.paidAt, isNull);
  });
}
