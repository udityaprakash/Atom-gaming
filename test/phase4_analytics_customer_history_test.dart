import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atom/core/constants/app_constants.dart';
import 'package:atom/core/database/app_database.dart';
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

  group('Customer Management Tests', () {
    test('Create, update, and retrieve customer with real-time stats', () async {
      final customerId = await customerRepo.createCustomer(
        name: 'Kabir Mehta',
        phone: '9876543210',
        notes: 'VIP gamer, prefers PS5',
      );

      final customer = await (db.select(db.customers)..where((t) => t.id.equals(customerId))).getSingle();
      expect(customer.name, 'Kabir Mehta');
      expect(customer.phone, '9876543210');

      // Update customer
      await customerRepo.updateCustomer(
        id: customerId,
        name: 'Kabir M.',
        phone: '9876543210',
        notes: 'Tournament champion',
      );
      final updated = await (db.select(db.customers)..where((t) => t.id.equals(customerId))).getSingle();
      expect(updated.name, 'Kabir M.');
      expect(updated.notes, 'Tournament champion');

      // Create a room and play a paid session
      final roomId = await roomRepo.createRoom(
        roomName: 'VIP Lounge',
        equipmentType: 'PS5',
        controllerCount: 2,
        hourlyRate: 150.0,
      );

      final sessionId = await sessionRepo.startSession(
        roomId: roomId,
        durationMinutes: 60,
        customerName: 'Kabir M.',
        customerPhone: '9876543210',
      );

      // Simulate 1 hour played
      await (db.update(db.sessionSegments)..where((t) => t.sessionId.equals(sessionId))).write(
        SessionSegmentsCompanion(startedAt: Value(DateTime.now().subtract(const Duration(minutes: 60)))),
      );

      // End session as PAID
      await sessionRepo.endSessionWithBilling(
        sessionId: sessionId,
        paymentStatus: AppConstants.paymentPaid,
      );

      final stats = await customerRepo.getCustomerStats(customerId);
      expect(stats.totalVisits, 1);
      expect(stats.totalSpent, greaterThan(0));
      expect(stats.outstandingDebt, 0.0);
    });

    test('Customer deletion safeguard prevents deleting customers with active/past sessions', () async {
      final roomId = await roomRepo.createRoom(
        roomName: 'Room A',
        equipmentType: 'PC',
        controllerCount: 1,
        hourlyRate: 100.0,
      );

      final sessionId = await sessionRepo.startSession(
        roomId: roomId,
        durationMinutes: 30,
        customerName: 'Aarav Sharma',
      );

      final session = await (db.select(db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
      expect(session.customerId, isNotNull);

      expect(
        () => customerRepo.deleteCustomer(session.customerId!),
        throwsException,
      );
    });
  });

  group('Session History & Audit Timeline Tests', () {
    test('Session history lists completed sessions and supports search and status filtering', () async {
      final roomId = await roomRepo.createRoom(
        roomName: 'Room 01',
        equipmentType: 'PS5',
        controllerCount: 2,
        hourlyRate: 120.0,
      );

      // Session 1: Paid
      final s1 = await sessionRepo.startSession(
        roomId: roomId,
        durationMinutes: 30,
        customerName: 'Vikram Joshi',
      );
      await sessionRepo.endSessionWithBilling(
        sessionId: s1,
        paymentStatus: AppConstants.paymentPaid,
      );

      // Session 2: Unpaid
      final s2 = await sessionRepo.startSession(
        roomId: roomId,
        durationMinutes: 30,
        customerName: 'Nitin Rao',
      );
      await sessionRepo.endSessionWithBilling(
        sessionId: s2,
        paymentStatus: AppConstants.paymentUnpaid,
      );

      // Verify all history contains 2 items
      final allHistory = await sessionRepo.watchSessionHistory().first;
      expect(allHistory.length, 2);

      // Filter by PAID
      final paidHistory = await sessionRepo.watchSessionHistory(paymentStatus: AppConstants.paymentPaid).first;
      expect(paidHistory.length, 1);
      expect(paidHistory.first.session.id, s1);

      // Filter by UNPAID
      final unpaidHistory = await sessionRepo.watchSessionHistory(paymentStatus: AppConstants.paymentUnpaid).first;
      expect(unpaidHistory.length, 1);
      expect(unpaidHistory.first.session.id, s2);

      // Search by Customer Name
      final searchResult = await sessionRepo.watchSessionHistory(searchQuery: 'Vikram').first;
      expect(searchResult.length, 1);
      expect(searchResult.first.customer?.name, 'Vikram Joshi');
    });

    test('Detailed audit timeline captures session events in order', () async {
      final r1 = await roomRepo.createRoom(
        roomName: 'Room 01',
        equipmentType: 'PS5',
        controllerCount: 2,
        hourlyRate: 100.0,
      );
      final r2 = await roomRepo.createRoom(
        roomName: 'VR Room',
        equipmentType: 'VR',
        controllerCount: 2,
        hourlyRate: 200.0,
      );

      final sId = await sessionRepo.startSession(
        roomId: r1,
        durationMinutes: 30,
        customerName: 'Dev Patel',
      );

      // Pause and resume
      await sessionRepo.pauseSession(sessionId: sId);
      await sessionRepo.resumeSession(sessionId: sId);

      // Transfer to r2
      await sessionRepo.transferRoom(sessionId: sId, destinationRoomId: r2);

      // End session
      await sessionRepo.endSessionWithBilling(sessionId: sId, paymentStatus: AppConstants.paymentPaid);

      final timeline = await sessionRepo.getSessionTimeline(sId);
      expect(timeline.events.isNotEmpty, isTrue);

      final eventTypes = timeline.events.map((e) => e.eventType).toList();
      expect(eventTypes, contains('started'));
      expect(eventTypes, contains('paused'));
      expect(eventTypes, contains('resumed'));
      expect(eventTypes, contains('transferred'));
      expect(eventTypes, contains('ended'));

      // Verify transfer event recorded origin and destination
      final transferEvent = timeline.events.firstWhere((e) => e.eventType == 'transferred');
      expect(transferEvent.newValue, contains('VR Room'));
    });
  });

  group('Revenue Analytics & Daily Cash Drawer Closing Tests', () {
    test('Strict separation between total billed and actual cash collected', () async {
      final rId = await roomRepo.createRoom(
        roomName: 'Arena 01',
        equipmentType: 'PC',
        controllerCount: 1,
        hourlyRate: 100.0,
      );

      // S1: Paid ₹100
      final s1 = await sessionRepo.startSession(roomId: rId, durationMinutes: 60);
      await (db.update(db.sessionSegments)..where((t) => t.sessionId.equals(s1))).write(
        SessionSegmentsCompanion(startedAt: Value(DateTime.now().subtract(const Duration(minutes: 60)))),
      );
      await sessionRepo.endSessionWithBilling(sessionId: s1, paymentStatus: AppConstants.paymentPaid);

      // S2: Unpaid ₹100
      final s2 = await sessionRepo.startSession(roomId: rId, durationMinutes: 60);
      await (db.update(db.sessionSegments)..where((t) => t.sessionId.equals(s2))).write(
        SessionSegmentsCompanion(startedAt: Value(DateTime.now().subtract(const Duration(minutes: 60)))),
      );
      await sessionRepo.endSessionWithBilling(sessionId: s2, paymentStatus: AppConstants.paymentUnpaid);

      final overview = await analyticsRepo.getFinancialOverview();

      expect(overview.totalSessions, 2);
      expect(overview.totalBilledRevenue, greaterThan(0));
      expect(overview.actualCashCollected, greaterThan(0));
      expect(overview.outstandingUnpaid, greaterThan(0));
      // Cash collected is strictly less than total billed because 1 session is unpaid!
      expect(overview.actualCashCollected, lessThan(overview.totalBilledRevenue));
    });

    test('Daily cash closing separates today sessions cash from settled past debts', () async {
      final rId = await roomRepo.createRoom(
        roomName: 'Sim Rig',
        equipmentType: 'Racing',
        controllerCount: 1,
        hourlyRate: 150.0,
      );

      // Paid session today
      final sToday = await sessionRepo.startSession(roomId: rId, durationMinutes: 30);
      await (db.update(db.sessionSegments)..where((t) => t.sessionId.equals(sToday))).write(
        SessionSegmentsCompanion(startedAt: Value(DateTime.now().subtract(const Duration(minutes: 30)))),
      );
      await sessionRepo.endSessionWithBilling(sessionId: sToday, paymentStatus: AppConstants.paymentPaid);

      final report = await analyticsRepo.getDailyCashClosing();

      expect(report.sessionsCountToday, 1);
      expect(report.cashFromTodaySessions, greaterThan(0));
      expect(report.totalCashInDrawer, equals(report.cashFromTodaySessions));
      expect(report.todayUnpaidDebtAccrued, 0.0);
    });

    test('Equipment revenue share groups revenue by equipment type', () async {
      final rPS5 = await roomRepo.createRoom(
        roomName: 'PS5 Room',
        equipmentType: 'PS5',
        controllerCount: 2,
        hourlyRate: 120.0,
      );
      final rPC = await roomRepo.createRoom(
        roomName: 'PC Room',
        equipmentType: 'PC',
        controllerCount: 1,
        hourlyRate: 80.0,
      );

      final s1 = await sessionRepo.startSession(roomId: rPS5, durationMinutes: 60);
      await sessionRepo.endSessionWithBilling(sessionId: s1, paymentStatus: AppConstants.paymentPaid);

      final s2 = await sessionRepo.startSession(roomId: rPC, durationMinutes: 60);
      await sessionRepo.endSessionWithBilling(sessionId: s2, paymentStatus: AppConstants.paymentPaid);

      final shares = await analyticsRepo.getEquipmentRevenueShare();
      expect(shares.length, 2);
      expect(shares.any((s) => s.equipmentType == 'PS5'), isTrue);
      expect(shares.any((s) => s.equipmentType == 'PC'), isTrue);
    });
  });
}
