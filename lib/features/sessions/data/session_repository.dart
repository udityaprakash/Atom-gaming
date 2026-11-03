import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';

class ActiveRoomSession {
  final Session session;
  final SessionSegment segment;
  final Room room;
  final Customer? customer;

  ActiveRoomSession({
    required this.session,
    required this.segment,
    required this.room,
    this.customer,
  });
}

class DashboardStats {
  final int totalRooms;
  final int availableRooms;
  final int occupiedRooms;
  final int maintenanceRooms;
  final int activeSessions;
  final int todayCompletedSessions;
  final double todayRevenue;
  final double todayUnpaidDues;

  const DashboardStats({
    this.totalRooms = 0,
    this.availableRooms = 0,
    this.occupiedRooms = 0,
    this.maintenanceRooms = 0,
    this.activeSessions = 0,
    this.todayCompletedSessions = 0,
    this.todayRevenue = 0.0,
    this.todayUnpaidDues = 0.0,
  });
}

class SessionRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  SessionRepository(this._db);

  Stream<List<ActiveRoomSession>> watchActiveRoomSessions() {
    // Join Sessions with active SessionSegments (endedAt is null), Room and optional Customer
    final query = _db.select(_db.sessions).join([
      innerJoin(
        _db.sessionSegments,
        _db.sessionSegments.sessionId.equalsExp(_db.sessions.id) &
            _db.sessionSegments.endedAt.isNull(),
      ),
      innerJoin(
        _db.rooms,
        _db.rooms.id.equalsExp(_db.sessionSegments.roomId),
      ),
      leftOuterJoin(
        _db.customers,
        _db.customers.id.equalsExp(_db.sessions.customerId),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ActiveRoomSession(
          session: row.readTable(_db.sessions),
          segment: row.readTable(_db.sessionSegments),
          room: row.readTable(_db.rooms),
          customer: row.readTableOrNull(_db.customers),
        );
      }).toList();
    });
  }

  Stream<ActiveRoomSession?> watchActiveSessionForRoom(String roomId) {
    return watchActiveRoomSessions().map((list) {
      try {
        return list.firstWhere((item) => item.room.id == roomId);
      } catch (_) {
        return null;
      }
    });
  }

  Future<String> startSession({
    required String roomId,
    required int durationMinutes,
    String? customerName,
    String? customerPhone,
    int? playerCount,
    int? controllerCount,
    String? notes,
  }) async {
    return await _db.transaction(() async {
      final now = DateTime.now();

      // 1. Verify Room exists and is Available
      final room = await (_db.select(_db.rooms)..where((t) => t.id.equals(roomId))).getSingleOrNull();
      if (room == null) {
        throw Exception('Room not found: $roomId');
      }
      if (room.status != AppConstants.statusAvailable) {
        throw Exception('Room "${room.roomName}" is not available (Current status: ${room.status})');
      }

      // 2. Handle optional Customer registration
      String? customerId;
      if (customerName != null && customerName.trim().isNotEmpty) {
        final existing = customerPhone != null && customerPhone.trim().isNotEmpty
            ? await (_db.select(_db.customers)..where((t) => t.phone.equals(customerPhone.trim()))).getSingleOrNull()
            : null;

        if (existing != null) {
          customerId = existing.id;
        } else {
          customerId = _uuid.v4();
          await _db.into(_db.customers).insert(
                CustomersCompanion(
                  id: Value(customerId),
                  name: Value(customerName.trim()),
                  phone: Value(customerPhone?.trim()),
                  notes: Value(notes?.trim()),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                ),
              );
        }
      }

      final sessionId = _uuid.v4();
      final scheduledEnd = now.add(Duration(minutes: durationMinutes));

      // 3. Insert Session
      await _db.into(_db.sessions).insert(
            SessionsCompanion(
              id: Value(sessionId),
              customerId: Value(customerId),
              status: const Value(AppConstants.sessionActive),
              startedAt: Value(now),
              scheduledEndAt: Value(scheduledEnd),
              billingPolicy: const Value('per_minute'),
              totalDurationSeconds: const Value(0),
              totalAmount: const Value(0.0),
              paymentStatus: const Value(AppConstants.paymentUnpaid),
              createdAt: Value(now),
            ),
          );

      // 4. Insert initial SessionSegment with Room's current price snapshot
      final segmentId = _uuid.v4();
      await _db.into(_db.sessionSegments).insert(
            SessionSegmentsCompanion(
              id: Value(segmentId),
              sessionId: Value(sessionId),
              roomId: Value(roomId),
              startedAt: Value(now),
              hourlyRateSnapshot: Value(room.hourlyRate),
              amount: const Value(0.0),
            ),
          );

      // 5. Update Room status to OCCUPIED
      await (_db.update(_db.rooms)..where((t) => t.id.equals(roomId))).write(
        RoomsCompanion(
          status: const Value(AppConstants.statusOccupied),
          updatedAt: Value(now),
        ),
      );

      // 6. Record Audit Event
      await _db.into(_db.sessionEvents).insert(
            SessionEventsCompanion(
              id: Value(_uuid.v4()),
              sessionId: Value(sessionId),
              eventType: const Value('started'),
              eventTimestamp: Value(now),
              newValue: Value('Duration: $durationMinutes min | Rate: ₹${room.hourlyRate}/hr'),
              notes: Value(notes?.trim()),
            ),
          );

      return sessionId;
    });
  }

  Future<void> endSession({
    required String sessionId,
    required String paymentStatus, // PAID or UNPAID
  }) async {
    await _db.transaction(() async {
      final now = DateTime.now();

      // 1. Fetch Session
      final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      if (session == null) {
        throw Exception('Session not found: $sessionId');
      }

      // 2. Fetch all segments for this session
      final segments = await (_db.select(_db.sessionSegments)
            ..where((t) => t.sessionId.equals(sessionId)))
          .get();

      double calculatedTotalAmount = 0.0;
      int calculatedTotalDurationSeconds = 0;
      String? activeRoomId;

      for (final segment in segments) {
        final segmentStart = segment.startedAt;
        final segmentEnd = segment.endedAt ?? now;
        final segmentDurationSecs = segmentEnd.difference(segmentStart).inSeconds;
        calculatedTotalDurationSeconds += segmentDurationSecs;

        // Calculate amount for segment (Per-minute calculation: Rate/60 per minute)
        final segmentMinutes = segmentDurationSecs / 60.0;
        final segmentAmount = (segmentMinutes / 60.0) * segment.hourlyRateSnapshot;
        calculatedTotalAmount += segmentAmount;

        // If this was the active unclosed segment, close it now
        if (segment.endedAt == null) {
          activeRoomId = segment.roomId;
          await (_db.update(_db.sessionSegments)..where((t) => t.id.equals(segment.id))).write(
            SessionSegmentsCompanion(
              endedAt: Value(now),
              amount: Value(segmentAmount),
            ),
          );
        }
      }

      // Round to nearest integer for billing (Indian Rupee practice)
      final finalAmount = calculatedTotalAmount.roundToDouble();

      // 3. Update Session
      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
        SessionsCompanion(
          status: const Value(AppConstants.sessionCompleted),
          endedAt: Value(now),
          totalDurationSeconds: Value(calculatedTotalDurationSeconds),
          totalAmount: Value(finalAmount),
          paymentStatus: Value(paymentStatus),
        ),
      );

      // 4. Create Payment Record (CASH ONLY)
      final isPaid = paymentStatus == AppConstants.paymentPaid;
      await _db.into(_db.payments).insert(
            PaymentsCompanion(
              id: Value(_uuid.v4()),
              sessionId: Value(sessionId),
              amountDue: Value(finalAmount),
              amountCollected: Value(isPaid ? finalAmount : 0.0),
              paymentMethod: const Value(AppConstants.methodCash),
              paymentStatus: Value(paymentStatus),
              paidAt: Value(isPaid ? now : null),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // 5. Restore Room to Available
      if (activeRoomId != null) {
        await (_db.update(_db.rooms)..where((t) => t.id.equals(activeRoomId!))).write(
          RoomsCompanion(
            status: const Value(AppConstants.statusAvailable),
            updatedAt: Value(now),
          ),
        );
      }

      // 6. Log Audit Events
      await _db.into(_db.sessionEvents).insert(
            SessionEventsCompanion(
              id: Value(_uuid.v4()),
              sessionId: Value(sessionId),
              eventType: const Value('ended'),
              eventTimestamp: Value(now),
              newValue: Value('Total: ₹$finalAmount | Payment: $paymentStatus'),
            ),
          );
    });
  }

  Stream<DashboardStats> watchDashboardStats() {
    // Combine room stream and payment stream
    return _db.select(_db.rooms).watch().asyncMap((rooms) async {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final totalRooms = rooms.where((r) => r.status != AppConstants.statusDeactivated).length;
      final availableRooms = rooms.where((r) => r.status == AppConstants.statusAvailable).length;
      final occupiedRooms = rooms.where((r) => r.status == AppConstants.statusOccupied || r.status == AppConstants.statusEndingSoon).length;
      final maintenanceRooms = rooms.where((r) => r.status == AppConstants.statusMaintenance).length;

      // Active sessions count
      final activeSessions = await (_db.select(_db.sessions)
            ..where((t) => t.status.equals(AppConstants.sessionActive) | t.status.equals(AppConstants.sessionOvertime)))
          .get();

      // Today's completed sessions
      final todayCompleted = await (_db.select(_db.sessions)
            ..where((t) => t.status.equals(AppConstants.sessionCompleted) & t.endedAt.isBiggerOrEqualValue(todayStart)))
          .get();

      // Today's cash collected
      final todayPayments = await (_db.select(_db.payments)
            ..where((t) => t.paidAt.isBiggerOrEqualValue(todayStart)))
          .get();

      final todayRevenue = todayPayments.fold<double>(0.0, (sum, p) => sum + p.amountCollected);

      // Today's unpaid dues from sessions ended today
      final todayUnpaidSessions = todayCompleted.where((s) => s.paymentStatus == AppConstants.paymentUnpaid);
      final todayUnpaidDues = todayUnpaidSessions.fold<double>(0.0, (sum, s) => sum + s.totalAmount);

      return DashboardStats(
        totalRooms: totalRooms,
        availableRooms: availableRooms,
        occupiedRooms: occupiedRooms,
        maintenanceRooms: maintenanceRooms,
        activeSessions: activeSessions.length,
        todayCompletedSessions: todayCompleted.length,
        todayRevenue: todayRevenue,
        todayUnpaidDues: todayUnpaidDues,
      );
    });
  }
}
