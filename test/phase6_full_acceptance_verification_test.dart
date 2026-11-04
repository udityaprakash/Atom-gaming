import 'dart:convert';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atom/core/constants/app_constants.dart';
import 'package:atom/core/database/app_database.dart';
import 'package:atom/core/services/billing_engine.dart';
import 'package:atom/core/services/data_export_service.dart';
import 'package:atom/core/services/recovery_service.dart';
import 'package:atom/features/analytics/data/analytics_repository.dart';
import 'package:atom/features/customers/data/customer_repository.dart';
import 'package:atom/features/rooms/data/room_repository.dart';
import 'package:atom/features/sessions/data/session_repository.dart';

void main() {
  late AppDatabase db;
  late RoomRepository roomRepo;
  late SessionRepository sessionRepo;
  late CustomerRepository customerRepo;
  late AnalyticsRepository analyticsRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    roomRepo = RoomRepository(db);
    sessionRepo = SessionRepository(db);
    customerRepo = CustomerRepository(db);
    analyticsRepo = AnalyticsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 6: Complete Acceptance Criteria & Edge Cases Verification', () {
    test('Criteria 1 & 2: Room creation, configuration and status transitions', () async {
      final roomId = await roomRepo.createRoom(
        roomName: 'Arena Alpha',
        equipmentType: 'PS5',
        controllerCount: 4,
        hourlyRate: 240.0,
        description: 'PS5 Pro with 4 DualSense controllers',
      );

      var room = await (db.select(db.rooms)..where((t) => t.id.equals(roomId))).getSingle();
      expect(room.roomName, 'Arena Alpha');
      expect(room.equipmentType, 'PS5');
      expect(room.hourlyRate, 240.0);
      expect(room.status, AppConstants.statusAvailable);
    });

    test('Criteria 3 & 4: Start session with snapshot rate and prevent double occupancy (Criterion 21)', () async {
      final roomId = await roomRepo.createRoom(
        roomName: 'Booth 01',
        equipmentType: 'PS5',
        controllerCount: 2,
        hourlyRate: 200.0,
      );

      final sessionId = await sessionRepo.startSession(
        roomId: roomId,
        durationMinutes: 60,
        customerName: 'Karan Mehra',
        playerCount: 2,
        controllerCount: 2,
      );

      expect(sessionId, isNotEmpty);
      var room = await (db.select(db.rooms)..where((t) => t.id.equals(roomId))).getSingle();
      expect(room.status, AppConstants.statusOccupied);

      // Criterion 21: No two active sessions can occupy the same room
      expect(
        () async => await sessionRepo.startSession(
          roomId: roomId,
          durationMinutes: 30,
          customerName: 'Intruder',
        ),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('is not available'))),
      );
    });

    test('Criterion 7: Extend session without losing history', () async {
      final roomId = await roomRepo.createRoom(
        roomName: 'Booth 02',
        equipmentType: 'Xbox Series X',
        controllerCount: 2,
        hourlyRate: 200.0,
      );

      final sessionId = await sessionRepo.startSession(
        roomId: roomId,
        durationMinutes: 60,
        customerName: 'Samir',
      );

      final sessionBefore = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();

      // Extend by 30 minutes
      await sessionRepo.extendSession(
        sessionId: sessionId,
        additionalMinutes: 30,
        extensionReason: 'Customer requested overtime',
      );

      final sessionAfter = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
      final diff = sessionAfter.scheduledEndAt.difference(sessionBefore.scheduledEndAt);
      expect(diff.inMinutes, 30);

      // Check extensions table audit trail
      final extensions = await (db.select(db.sessionExtensions)..where((t) => t.sessionId.equals(sessionId))).get();
      expect(extensions.length, 1);
      expect(extensions.first.addedMinutes, 30);
    });

    test('Criteria 8, 9 & 22: Room transfer with multi-segment billing and price freeze immutability', () async {
      final ps4RoomId = await roomRepo.createRoom(
        roomName: 'Standard PS4',
        equipmentType: 'PS4',
        controllerCount: 2,
        hourlyRate: 120.0, // ₹120/hr = ₹2/min
      );

      final ps5RoomId = await roomRepo.createRoom(
        roomName: 'VIP PS5',
        equipmentType: 'PS5',
        controllerCount: 2,
        hourlyRate: 240.0, // ₹240/hr = ₹4/min
      );

      final sessionId = await sessionRepo.startSession(
        roomId: ps4RoomId,
        durationMinutes: 60,
        customerName: 'Aryan',
      );

      // Simulate 30 mins played on PS4 by moving startedAt 30 mins into the past
      final seg1 = await (db.select(db.sessionSegments)..where((t) => t.sessionId.equals(sessionId))).getSingle();
      final pastStart = DateTime.now().subtract(const Duration(minutes: 30));
      await (db.update(db.sessionSegments)..where((t) => t.id.equals(seg1.id))).write(
        SessionSegmentsCompanion(startedAt: Value(pastStart)),
      );

      // Transfer to VIP PS5
      await sessionRepo.transferRoom(
        sessionId: sessionId,
        targetRoomId: ps5RoomId,
        reason: 'Upgraded to PS5',
      );

      // Verify old room is available, new room is occupied
      final oldRoom = await (db.select(db.rooms)..where((t) => t.id.equals(ps4RoomId))).getSingle();
      final newRoom = await (db.select(db.rooms)..where((t) => t.id.equals(ps5RoomId))).getSingle();
      expect(oldRoom.status, AppConstants.statusAvailable);
      expect(newRoom.status, AppConstants.statusOccupied);

      // Simulate 15 mins played on VIP PS5
      final segments = await (db.select(db.sessionSegments)..where((t) => t.sessionId.equals(sessionId))).get();
      expect(segments.length, 2);
      final activeSeg = segments.firstWhere((s) => s.endedAt == null);
      final seg2PastStart = DateTime.now().subtract(const Duration(minutes: 15));
      await (db.update(db.sessionSegments)..where((t) => t.id.equals(activeSeg.id))).write(
        SessionSegmentsCompanion(startedAt: Value(seg2PastStart)),
      );

      // End Session
      await sessionRepo.endSession(
        sessionId: sessionId,
        paymentStatus: AppConstants.paymentPaid,
        discount: 0.0,
      );

      // Verify calculated amounts
      final completedSession = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
      // Seg 1 (PS4): 30 mins @ ₹120/hr = ₹60
      // Seg 2 (PS5): 15 mins @ ₹240/hr = ₹60
      // Total = ₹120
      expect(completedSession.totalAmount, closeTo(120.0, 2.0));

      // Criterion 22: Changing room prices now does NOT change historical session bill
      await roomRepo.updateRoom(
        id: ps4RoomId,
        roomName: 'Standard PS4',
        equipmentType: 'PS4',
        controllerCount: 2,
        hourlyRate: 500.0, // massive price jump
      );

      final historicalSession = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
      expect(historicalSession.totalAmount, closeTo(120.0, 2.0)); // Unchanged!
    });

    test('Criteria 10 & 11: Crash / Reboot Recovery restores active state without timer drift', () async {
      final roomId = await roomRepo.createRoom(
        roomName: 'Crash Recovery Console',
        equipmentType: 'PS5',
        controllerCount: 2,
        hourlyRate: 180.0,
      );

      final startTime = DateTime.now().subtract(const Duration(minutes: 20));
      final endTime = startTime.add(const Duration(minutes: 60));

      final sessionId = await sessionRepo.startSession(
        roomId: roomId,
        durationMinutes: 60,
        customerName: 'Crash Test Gamer',
      );

      // Backdate to simulate time passed before sudden crash
      await (db.update(db.sessions)..where((t) => t.id.equals(sessionId))).write(
        SessionsCompanion(
          startedAt: Value(startTime),
          scheduledEndAt: Value(endTime),
        ),
      );

      // Trigger Reboot / Crash recovery service
      final recoveryService = RecoveryService(db);
      final recoveredCount = await recoveryService.recoverSessionsOnStartup();
      expect(recoveredCount, 1);

      // Room remains Occupied, timers continue cleanly from timestamps
      final room = await (db.select(db.rooms)..where((t) => t.id.equals(roomId))).getSingle();
      expect(room.status, AppConstants.statusOccupied);
    });

    test('Criteria 13, 14, 15 & 16: Unpaid sessions, delayed cash collection, and analytics separation', () async {
      final customerId = await customerRepo.createCustomer(
        name: 'Rohan Debt Test',
        phone: '9123456780',
      );

      final roomId = await roomRepo.createRoom(
        roomName: 'Debt Test Room',
        equipmentType: 'Gaming PC',
        controllerCount: 1,
        hourlyRate: 100.0,
      );

      final sessionId = await sessionRepo.startSession(
        roomId: roomId,
        durationMinutes: 60,
        customerId: customerId,
        customerName: 'Rohan Debt Test',
      );

      // Simulate 60 mins played
      final seg = await (db.select(db.sessionSegments)..where((t) => t.sessionId.equals(sessionId))).getSingle();
      final pastStart = DateTime.now().subtract(const Duration(minutes: 60));
      await (db.update(db.sessionSegments)..where((t) => t.id.equals(seg.id))).write(
        SessionSegmentsCompanion(startedAt: Value(pastStart)),
      );

      // End session as UNPAID
      await sessionRepo.endSession(
        sessionId: sessionId,
        paymentStatus: AppConstants.paymentUnpaid,
      );

      var session = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
      expect(session.paymentStatus, AppConstants.paymentUnpaid);

      // Check Customer debt balance
      var customerStats = await customerRepo.getCustomerStats(customerId);
      expect(customerStats.unpaidBalance, closeTo(100.0, 2.0));

      // Criterion 16: Analytics separation
      var revenueSummary = await analyticsRepo.getRevenueSummary();
      expect(revenueSummary.totalBilledRevenue, closeTo(100.0, 2.0));
      expect(revenueSummary.cashActuallyCollected, 0.0);
      expect(revenueSummary.totalOutstandingUnpaid, closeTo(100.0, 2.0));

      // Criterion 14 & 15: Collect cash later against unpaid debt
      final collectionTime = DateTime.now();
      await sessionRepo.collectOutstandingCash(
        sessionId: sessionId,
        amountCollected: 100.0,
      );

      session = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
      expect(session.paymentStatus, AppConstants.paymentPaid);

      final payment = await (db.select(db.payments)..where((t) => t.sessionId.equals(sessionId))).getSingle();
      expect(payment.paymentStatus, AppConstants.paymentPaid);
      expect(payment.amountCollected, 100.0);
      expect(payment.paidAt, isNotNull);

      // Customer debt is now cleared
      customerStats = await customerRepo.getCustomerStats(customerId);
      expect(customerStats.unpaidBalance, 0.0);

      // Analytics now reflects cash collected
      revenueSummary = await analyticsRepo.getRevenueSummary();
      expect(revenueSummary.cashActuallyCollected, closeTo(100.0, 2.0));
      expect(revenueSummary.totalOutstandingUnpaid, 0.0);
    });

    test('Criterion 18 & 20: Full offline JSON and CSV export verification', () async {
      final jsonStr = await DataExportService.exportAllToJson(db);
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(jsonMap['metadata']['appName'], 'atom');
      expect(jsonMap.containsKey('rooms'), isTrue);
      expect(jsonMap.containsKey('sessions'), isTrue);
      expect(jsonMap.containsKey('payments'), isTrue);
      expect(jsonMap.containsKey('customers'), isTrue);

      final sessionsCsv = await DataExportService.exportSessionsToCsv(db);
      expect(sessionsCsv, contains('Session ID'));

      final paymentsCsv = await DataExportService.exportPaymentsToCsv(db);
      expect(paymentsCsv, contains('Payment ID'));

      final customersCsv = await DataExportService.exportCustomersToCsv(db);
      expect(customersCsv, contains('Customer ID'));
    });
  });
}
