import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atom/core/constants/app_constants.dart';
import 'package:atom/core/database/app_database.dart';
import 'package:atom/core/services/billing_engine.dart';
import 'package:atom/core/services/receipt_service.dart';
import 'package:atom/features/rooms/data/room_repository.dart';
import 'package:atom/features/sessions/data/session_repository.dart';

void main() {
  group('BillingEngine Unit Tests', () {
    test('Per-minute billing policy calculates exact elapsed minutes', () {
      final mins = BillingEngine.calculateBillableMinutes(
        const Duration(minutes: 45, seconds: 30),
        policy: 'per_minute',
      );
      expect(mins, closeTo(45.5, 0.001));
    });

    test('15-minute block billing policy rounds up and respects grace period', () {
      // 14 minutes -> rounds to 15m
      expect(
        BillingEngine.calculateBillableMinutes(const Duration(minutes: 14), policy: 'blocks_15'),
        15.0,
      );

      // 16 minutes with 2 min grace period (16 % 15 = 1 <= 2) -> rounds down to 15m
      expect(
        BillingEngine.calculateBillableMinutes(
          const Duration(minutes: 16),
          policy: 'blocks_15',
          gracePeriodMinutes: 2,
        ),
        15.0,
      );

      // 18 minutes with 2 min grace period (18 % 15 = 3 > 2) -> rounds up to 30m
      expect(
        BillingEngine.calculateBillableMinutes(
          const Duration(minutes: 18),
          policy: 'blocks_15',
          gracePeriodMinutes: 2,
        ),
        30.0,
      );
    });

    test('30-minute block billing policy rounds correctly', () {
      expect(
        BillingEngine.calculateBillableMinutes(const Duration(minutes: 35), policy: 'blocks_30'),
        60.0,
      );
      expect(
        BillingEngine.calculateBillableMinutes(
          const Duration(minutes: 32),
          policy: 'blocks_30',
          gracePeriodMinutes: 3,
        ),
        30.0,
      );
    });

    test('Segment calculation respects minimum charge threshold', () {
      // 5 minutes at ₹120/hr is ₹10 raw, but minimum charge is ₹30
      final amount = BillingEngine.calculateSegmentAmount(
        duration: const Duration(minutes: 5),
        hourlyRateSnapshot: 120.0,
        policy: 'per_minute',
        minimumCharge: 30.0,
      );
      expect(amount, 30.0);
    });

    test('calculateSessionBreakdown aggregates multiple segments and applies discount', () {
      final seg1 = SegmentBillingDetails(
        roomId: 'r1',
        roomName: 'Room 1 (PS5)',
        equipmentType: 'PS5 Pro',
        startedAt: DateTime(2026, 11, 3, 10, 0),
        endedAt: DateTime(2026, 11, 3, 10, 30),
        duration: const Duration(minutes: 30),
        hourlyRateSnapshot: 200.0,
        amount: 100.0,
      );

      final seg2 = SegmentBillingDetails(
        roomId: 'r2',
        roomName: 'Room 2 (VR)',
        equipmentType: 'VR Headset',
        startedAt: DateTime(2026, 11, 3, 10, 30),
        endedAt: DateTime(2026, 11, 3, 11, 0),
        duration: const Duration(minutes: 30),
        hourlyRateSnapshot: 300.0,
        amount: 150.0,
      );

      final breakdown = BillingEngine.calculateSessionBreakdown(
        segments: [seg1, seg2],
        discount: 25.0,
      );

      expect(breakdown.totalDuration.inMinutes, 60);
      expect(breakdown.grossAmount, 250.0);
      expect(breakdown.discount, 25.0);
      expect(breakdown.finalAmount, 225.0);
    });
  });

  group('ReceiptService Plain Text Formatting', () {
    test('Formats full paid receipt with multiple segments, extensions, and cash status', () {
      final receiptData = SessionReceiptData(
        sessionId: 'test-session-12345678',
        customerName: 'Aarav Patel',
        customerPhone: '+91 99887 76655',
        startedAt: DateTime(2026, 11, 3, 14, 0),
        endedAt: DateTime(2026, 11, 3, 15, 30),
        totalDuration: const Duration(minutes: 90),
        segments: [
          SegmentBillingDetails(
            roomId: 'r1',
            roomName: 'Room 1 (PS5)',
            equipmentType: 'PS5 Pro',
            startedAt: DateTime(2026, 11, 3, 14, 0),
            endedAt: DateTime(2026, 11, 3, 14, 45),
            duration: const Duration(minutes: 45),
            hourlyRateSnapshot: 200.0,
            amount: 150.0,
          ),
          SegmentBillingDetails(
            roomId: 'r2',
            roomName: 'Room 2 (VR)',
            equipmentType: 'VR Simulator',
            startedAt: DateTime(2026, 11, 3, 14, 45),
            endedAt: DateTime(2026, 11, 3, 15, 30),
            duration: const Duration(minutes: 45),
            hourlyRateSnapshot: 300.0,
            amount: 225.0,
          ),
        ],
        extensionCount: 1,
        totalExtensionMinutes: 15,
        grossAmount: 375.0,
        discount: 25.0,
        finalAmount: 350.0,
        paymentStatus: 'PAID',
        paymentMethod: 'CASH',
        paidAt: DateTime(2026, 11, 3, 15, 31),
        notes: 'VIP gamer discount',
      );

      final text = ReceiptService.formatReceiptText(receiptData);

      expect(text, contains('ATOM GAMING LOUNGE'));
      expect(text, contains('Aarav Patel'));
      expect(text, contains('+91 99887 76655'));
      expect(text, contains('Room 1 (PS5) [PS5 Pro]'));
      expect(text, contains('Room 2 (VR) [VR Simulator]'));
      expect(text, contains('Extensions : 1 (+15 mins)'));
      expect(text, contains('TOTAL PAYABLE  : ₹350'));
      expect(text, contains('PAYMENT METHOD : CASH (CASH ONLY)'));
      expect(text, contains('PAYMENT STATUS : PAID IN FULL (CASH)'));
      expect(text, contains('Notes          : VIP gamer discount'));
    });

    test('Formats unpaid receipt with balance due notice', () {
      final receiptData = SessionReceiptData(
        sessionId: 'test-session-unpaid',
        customerName: 'Kunal Singh',
        startedAt: DateTime(2026, 11, 3, 16, 0),
        endedAt: DateTime(2026, 11, 3, 17, 0),
        totalDuration: const Duration(minutes: 60),
        segments: [
          SegmentBillingDetails(
            roomId: 'r1',
            roomName: 'Room 1',
            equipmentType: 'Xbox',
            startedAt: DateTime(2026, 11, 3, 16, 0),
            endedAt: DateTime(2026, 11, 3, 17, 0),
            duration: const Duration(minutes: 60),
            hourlyRateSnapshot: 150.0,
            amount: 150.0,
          ),
        ],
        grossAmount: 150.0,
        finalAmount: 150.0,
        paymentStatus: 'UNPAID',
      );

      final text = ReceiptService.formatReceiptText(receiptData);

      expect(text, contains('PAYMENT STATUS : UNPAID (PENDING DEBT)'));
      expect(text, contains('BALANCE DUE    : ₹150'));
      expect(text, contains('** Please settle outstanding cash at desk **'));
    });
  });

  group('SessionRepository Phase 3 Database & Cash Collection Tests', () {
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

    test('Multi-segment session with room transfer bills both rooms and marks PAID in cash', () async {
      final room1Id = await roomRepo.createRoom(
        roomName: 'PS5 Lounge',
        equipmentType: 'PS5',
        controllerCount: 2,
        hourlyRate: 120.0,
      );
      final room2Id = await roomRepo.createRoom(
        roomName: 'VR Station',
        equipmentType: 'VR',
        controllerCount: 2,
        hourlyRate: 240.0,
      );

      final sessionId = await sessionRepo.startSession(
        roomId: room1Id,
        durationMinutes: 60,
        customerName: 'Sameer Khan',
        customerPhone: '9876543210',
      );

      // Transfer from room1 to room2
      await sessionRepo.transferRoom(
        sessionId: sessionId,
        destinationRoomId: room2Id,
      );

      // Verify origin room is back to available and destination room is occupied
      final r1 = await (db.select(db.rooms)..where((t) => t.id.equals(room1Id))).getSingle();
      final r2 = await (db.select(db.rooms)..where((t) => t.id.equals(room2Id))).getSingle();
      expect(r1.status, AppConstants.statusAvailable);
      expect(r2.status, AppConstants.statusOccupied);

      // End session with full billing and PAID cash status with ₹10 discount
      final receipt = await sessionRepo.endSessionWithBilling(
        sessionId: sessionId,
        paymentStatus: AppConstants.paymentPaid,
        discount: 10.0,
        notes: 'Transfer bonus',
      );

      expect(receipt.paymentStatus, AppConstants.paymentPaid);
      expect(receipt.paymentMethod, AppConstants.methodCash);
      expect(receipt.segments.length, 2);
      expect(receipt.discount, 10.0);
      expect(receipt.paidAt, isNotNull);

      // Verify Destination room is now AVAILABLE
      final r2After = await (db.select(db.rooms)..where((t) => t.id.equals(room2Id))).getSingle();
      expect(r2After.status, AppConstants.statusAvailable);

      // Verify Payment record in database
      final payment = await (db.select(db.payments)..where((t) => t.sessionId.equals(sessionId))).getSingle();
      expect(payment.paymentMethod, AppConstants.methodCash);
      expect(payment.paymentStatus, AppConstants.paymentPaid);
      expect(payment.amountCollected, payment.amountDue);
      expect(payment.paidAt, isNotNull);

      // Verify Audit Event
      final events = await sessionRepo.getSessionEvents(sessionId);
      final endEvent = events.firstWhere((e) => e.eventType == 'ended');
      expect(endEvent.newValue, contains('PAID (CASH)'));
    });

    test('Unpaid session appears in watchUnpaidSessions and can be settled later via collectOutstandingCash', () async {
      final roomId = await roomRepo.createRoom(
        roomName: 'PC Station 01',
        equipmentType: 'PC',
        controllerCount: 1,
        hourlyRate: 100.0,
      );

      final sessionId = await sessionRepo.startSession(
        roomId: roomId,
        durationMinutes: 30,
        customerName: 'Rohan Verma',
      );

      // End session as UNPAID
      final receipt = await sessionRepo.endSessionWithBilling(
        sessionId: sessionId,
        paymentStatus: AppConstants.paymentUnpaid,
      );

      expect(receipt.paymentStatus, AppConstants.paymentUnpaid);
      expect(receipt.paidAt, isNull);

      final sessionAfterEnd = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
      final originalEndedAt = sessionAfterEnd.endedAt;
      expect(originalEndedAt, isNotNull);

      // Verify Payment record has collected = 0 and status = UNPAID
      final paymentBefore = await (db.select(db.payments)..where((t) => t.sessionId.equals(sessionId))).getSingle();
      expect(paymentBefore.paymentStatus, AppConstants.paymentUnpaid);
      expect(paymentBefore.amountCollected, 0.0);
      expect(paymentBefore.paidAt, isNull);

      // Verify it appears in watchUnpaidSessions stream
      final unpaidList = await sessionRepo.watchUnpaidSessions().first;
      expect(unpaidList.any((u) => u.session.id == sessionId), isTrue);

      // Settle debt later via collectOutstandingCash
      await sessionRepo.collectOutstandingCash(sessionId: sessionId);

      // Verify Session is now PAID
      final sessionAfterSettle = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
      expect(sessionAfterSettle.paymentStatus, AppConstants.paymentPaid);
      // Preserved original completion timestamp
      expect(sessionAfterSettle.endedAt, equals(originalEndedAt));

      // Verify Payment record is updated with actual collection timestamp
      final paymentAfter = await (db.select(db.payments)..where((t) => t.sessionId.equals(sessionId))).getSingle();
      expect(paymentAfter.paymentStatus, AppConstants.paymentPaid);
      expect(paymentAfter.amountCollected, paymentAfter.amountDue);
      expect(paymentAfter.paidAt, isNotNull);

      // Verify Audit Event 'unpaid_settled' is created
      final events = await sessionRepo.getSessionEvents(sessionId);
      final settledEvent = events.firstWhere((e) => e.eventType == 'unpaid_settled');
      expect(settledEvent.newValue, contains('PAID IN CASH'));

      // Verify session is no longer in watchUnpaidSessions stream
      final unpaidListAfter = await sessionRepo.watchUnpaidSessions().first;
      expect(unpaidListAfter.any((u) => u.session.id == sessionId), isFalse);

      // Verify getSessionReceiptData reflects settled state
      final updatedReceipt = await sessionRepo.getSessionReceiptData(sessionId);
      expect(updatedReceipt.paymentStatus, AppConstants.paymentPaid);
      expect(updatedReceipt.paidAt, isNotNull);
    });
  });
}
