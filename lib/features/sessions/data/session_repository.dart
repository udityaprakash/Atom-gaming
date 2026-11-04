import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/alarm_service.dart';
import '../../../core/services/billing_engine.dart';
import '../../../core/services/receipt_service.dart';

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

class UnpaidSessionItem {
  final Session session;
  final Customer? customer;
  final Room room;
  final Payment? payment;
  final DateTime endedAt;
  final double amountDue;

  const UnpaidSessionItem({
    required this.session,
    this.customer,
    required this.room,
    this.payment,
    required this.endedAt,
    required this.amountDue,
  });
}

class HistoricalSessionItem {
  final Session session;
  final Customer? customer;
  final List<SessionSegment> segments;
  final List<Room> rooms;
  final Payment? payment;
  final int extensionCount;

  const HistoricalSessionItem({
    required this.session,
    this.customer,
    required this.segments,
    required this.rooms,
    this.payment,
    this.extensionCount = 0,
  });

  String get roomDisplay {
    if (rooms.isEmpty) return 'Gaming Room';
    if (rooms.length == 1) return '${rooms.first.roomName} (${rooms.first.equipmentType})';
    return rooms.map((r) => r.roomName).join(' ➔ ');
  }
}

class DetailedSessionTimeline {
  final HistoricalSessionItem sessionItem;
  final List<SessionEvent> events;
  final List<SessionExtension> extensions;

  const DetailedSessionTimeline({
    required this.sessionItem,
    required this.events,
    required this.extensions,
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
  final AlarmService? _alarmService;
  final _uuid = const Uuid();

  SessionRepository(this._db, [this._alarmService]);

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
    final sessionId = await _db.transaction(() async {
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

      final sid = _uuid.v4();
      final scheduledEnd = now.add(Duration(minutes: durationMinutes));

      // 3. Insert Session
      await _db.into(_db.sessions).insert(
            SessionsCompanion(
              id: Value(sid),
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
              sessionId: Value(sid),
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
              sessionId: Value(sid),
              eventType: const Value('started'),
              eventTimestamp: Value(now),
              newValue: Value('Duration: $durationMinutes min | Rate: ₹${room.hourlyRate}/hr'),
              notes: Value(notes?.trim()),
            ),
          );

      return sid;
    });

    // Schedule background alert
    if (_alarmService != null) {
      final room = await (_db.select(_db.rooms)..where((t) => t.id.equals(roomId))).getSingleOrNull();
      final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      if (room != null && session != null) {
        await _alarmService.scheduleSessionAlert(
          sessionId: sessionId,
          roomName: room.roomName,
          scheduledEndAt: session.scheduledEndAt,
        );
      }
    }

    return sessionId;
  }

  /// Extend an active or overtime session by [extensionMinutes]
  Future<void> extendSession({
    required String sessionId,
    required int extensionMinutes,
  }) async {
    DateTime newScheduledEnd = DateTime.now();
    String roomName = '';

    await _db.transaction(() async {
      final now = DateTime.now();

      final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      if (session == null) throw Exception('Session not found: $sessionId');

      final prevEnd = session.scheduledEndAt;
      // If session was already past scheduled end, extend from now or from prevEnd
      final baseTime = prevEnd.isBefore(now) ? now : prevEnd;
      newScheduledEnd = baseTime.add(Duration(minutes: extensionMinutes));

      // 1. Record extension in SessionExtensions table
      await _db.into(_db.sessionExtensions).insert(
            SessionExtensionsCompanion(
              id: Value(_uuid.v4()),
              sessionId: Value(sessionId),
              previousEndTime: Value(prevEnd),
              newEndTime: Value(newScheduledEnd),
              extensionMinutes: Value(extensionMinutes),
              createdAt: Value(now),
            ),
          );

      // 2. Update Sessions scheduledEndAt & ensure status is ACTIVE
      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
        SessionsCompanion(
          scheduledEndAt: Value(newScheduledEnd),
          status: const Value(AppConstants.sessionActive),
        ),
      );

      // 3. Find active room and ensure its status is OCCUPIED
      final activeSegment = await (_db.select(_db.sessionSegments)
            ..where((t) => t.sessionId.equals(sessionId) & t.endedAt.isNull()))
          .getSingleOrNull();

      if (activeSegment != null) {
        final room = await (_db.select(_db.rooms)..where((t) => t.id.equals(activeSegment.roomId))).getSingleOrNull();
        if (room != null) {
          roomName = room.roomName;
          await (_db.update(_db.rooms)..where((t) => t.id.equals(room.id))).write(
            RoomsCompanion(
              status: const Value(AppConstants.statusOccupied),
              updatedAt: Value(now),
            ),
          );
        }
      }

      // 4. Log Audit Event
      await _db.into(_db.sessionEvents).insert(
            SessionEventsCompanion(
              id: Value(_uuid.v4()),
              sessionId: Value(sessionId),
              eventType: const Value('extended'),
              eventTimestamp: Value(now),
              oldValue: Value('End: $prevEnd'),
              newValue: Value('End: $newScheduledEnd (+ $extensionMinutes min)'),
            ),
          );
    });

    // Reschedule OS Alarm for new end time
    if (_alarmService != null && roomName.isNotEmpty) {
      await _alarmService.scheduleSessionAlert(
        sessionId: sessionId,
        roomName: roomName,
        scheduledEndAt: newScheduledEnd,
      );
    }
  }

  /// Pause an active session: stops countdown, halts billable accumulation
  Future<void> pauseSession({required String sessionId}) async {
    await _db.transaction(() async {
      final now = DateTime.now();

      final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      if (session == null) throw Exception('Session not found: $sessionId');

      // 1. Update Session status to PAUSED
      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
        const SessionsCompanion(status: Value(AppConstants.sessionPaused)),
      );

      // 2. Update active room to PAUSED
      final activeSegment = await (_db.select(_db.sessionSegments)
            ..where((t) => t.sessionId.equals(sessionId) & t.endedAt.isNull()))
          .getSingleOrNull();

      if (activeSegment != null) {
        await (_db.update(_db.rooms)..where((t) => t.id.equals(activeSegment.roomId))).write(
          RoomsCompanion(
            status: const Value(AppConstants.statusPaused),
            updatedAt: Value(now),
          ),
        );
      }

      // 3. Record Audit Event with pause timestamp
      await _db.into(_db.sessionEvents).insert(
            SessionEventsCompanion(
              id: Value(_uuid.v4()),
              sessionId: Value(sessionId),
              eventType: const Value('paused'),
              eventTimestamp: Value(now),
              newValue: Value('Session paused at $now'),
            ),
          );
    });

    // Cancel pending alarm while paused
    if (_alarmService != null) {
      await _alarmService.cancelSessionAlert(sessionId);
    }
  }

  /// Resume a paused session: calculates paused duration, pushes scheduledEndAt forward
  Future<void> resumeSession({required String sessionId}) async {
    DateTime newScheduledEnd = DateTime.now();
    String roomName = '';

    await _db.transaction(() async {
      final now = DateTime.now();

      final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      if (session == null) throw Exception('Session not found: $sessionId');

      // 1. Find last pause event to determine paused duration
      final lastPause = await (_db.select(_db.sessionEvents)
            ..where((t) => t.sessionId.equals(sessionId) & t.eventType.equals('paused'))
            ..orderBy([(t) => OrderingTerm(expression: t.eventTimestamp, mode: OrderingMode.desc)])
            ..limit(1))
          .getSingleOrNull();

      final pauseDuration = lastPause != null ? now.difference(lastPause.eventTimestamp) : Duration.zero;
      newScheduledEnd = session.scheduledEndAt.add(pauseDuration);

      // 2. Update Session status to ACTIVE & adjust scheduledEndAt
      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
        SessionsCompanion(
          status: const Value(AppConstants.sessionActive),
          scheduledEndAt: Value(newScheduledEnd),
        ),
      );

      // 3. Update active room back to OCCUPIED
      final activeSegment = await (_db.select(_db.sessionSegments)
            ..where((t) => t.sessionId.equals(sessionId) & t.endedAt.isNull()))
          .getSingleOrNull();

      if (activeSegment != null) {
        final room = await (_db.select(_db.rooms)..where((t) => t.id.equals(activeSegment.roomId))).getSingleOrNull();
        if (room != null) {
          roomName = room.roomName;
          await (_db.update(_db.rooms)..where((t) => t.id.equals(room.id))).write(
            RoomsCompanion(
              status: const Value(AppConstants.statusOccupied),
              updatedAt: Value(now),
            ),
          );
        }
      }

      // 4. Log Audit Event
      await _db.into(_db.sessionEvents).insert(
            SessionEventsCompanion(
              id: Value(_uuid.v4()),
              sessionId: Value(sessionId),
              eventType: const Value('resumed'),
              eventTimestamp: Value(now),
              oldValue: Value('Pause duration: ${pauseDuration.inMinutes} min'),
              newValue: Value('New end time: $newScheduledEnd'),
            ),
          );
    });

    // Reschedule OS Alarm
    if (_alarmService != null && roomName.isNotEmpty) {
      await _alarmService.scheduleSessionAlert(
        sessionId: sessionId,
        roomName: roomName,
        scheduledEndAt: newScheduledEnd,
      );
    }
  }

  /// Transfer customer session to a new room: closes old segment at its rate snapshot,
  /// frees old room, opens new segment at new rate snapshot, marks destination room OCCUPIED.
  Future<void> transferRoom({
    required String sessionId,
    required String destinationRoomId,
  }) async {
    String destRoomName = '';
    DateTime scheduledEnd = DateTime.now();

    await _db.transaction(() async {
      final now = DateTime.now();

      // 1. Verify Destination Room is Available
      final destRoom = await (_db.select(_db.rooms)..where((t) => t.id.equals(destinationRoomId))).getSingleOrNull();
      if (destRoom == null) throw Exception('Destination room not found: $destinationRoomId');
      if (destRoom.status != AppConstants.statusAvailable) {
        throw Exception('Destination room "${destRoom.roomName}" is not available (${destRoom.status})');
      }
      destRoomName = destRoom.roomName;

      // 2. Fetch Session & active Segment
      final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      if (session == null) throw Exception('Session not found: $sessionId');
      scheduledEnd = session.scheduledEndAt;

      final activeSegment = await (_db.select(_db.sessionSegments)
            ..where((t) => t.sessionId.equals(sessionId) & t.endedAt.isNull()))
          .getSingleOrNull();
      if (activeSegment == null) throw Exception('No active segment found for session $sessionId');

      final originRoom = await (_db.select(_db.rooms)..where((t) => t.id.equals(activeSegment.roomId))).getSingleOrNull();

      // 3. Close the active segment: calculate played minutes & charge snapshot
      final segmentMinutes = now.difference(activeSegment.startedAt).inSeconds / 60.0;
      final segmentAmount = (segmentMinutes / 60.0) * activeSegment.hourlyRateSnapshot;

      await (_db.update(_db.sessionSegments)..where((t) => t.id.equals(activeSegment.id))).write(
        SessionSegmentsCompanion(
          endedAt: Value(now),
          amount: Value(segmentAmount),
        ),
      );

      // 4. Free origin room -> Set to AVAILABLE
      await (_db.update(_db.rooms)..where((t) => t.id.equals(activeSegment.roomId))).write(
        RoomsCompanion(
          status: const Value(AppConstants.statusAvailable),
          updatedAt: Value(now),
        ),
      );

      // 5. Create new SessionSegment with destination room's rate snapshot
      final newSegmentId = _uuid.v4();
      await _db.into(_db.sessionSegments).insert(
            SessionSegmentsCompanion(
              id: Value(newSegmentId),
              sessionId: Value(sessionId),
              roomId: Value(destinationRoomId),
              startedAt: Value(now),
              hourlyRateSnapshot: Value(destRoom.hourlyRate),
              amount: const Value(0.0),
            ),
          );

      // 6. Set Destination Room status to OCCUPIED
      await (_db.update(_db.rooms)..where((t) => t.id.equals(destinationRoomId))).write(
        RoomsCompanion(
          status: const Value(AppConstants.statusOccupied),
          updatedAt: Value(now),
        ),
      );

      // 7. Log Transfer in SessionEvents
      await _db.into(_db.sessionEvents).insert(
            SessionEventsCompanion(
              id: Value(_uuid.v4()),
              sessionId: Value(sessionId),
              eventType: const Value('transferred'),
              eventTimestamp: Value(now),
              oldValue: Value('${originRoom?.roomName ?? "Room"} (₹${activeSegment.hourlyRateSnapshot}/hr)'),
              newValue: Value('${destRoom.roomName} (₹${destRoom.hourlyRate}/hr)'),
            ),
          );
    });

    // Update OS alarm for destination room name
    if (_alarmService != null) {
      await _alarmService.cancelSessionAlert(sessionId);
      await _alarmService.scheduleSessionAlert(
        sessionId: sessionId,
        roomName: destRoomName,
        scheduledEndAt: scheduledEnd,
      );
    }
  }

  /// Calculate live billing preview for an ongoing session
  Future<SessionBillingBreakdown> calculateLiveSessionBreakdown(
    String sessionId, {
    double discount = 0.0,
  }) async {
    final now = DateTime.now();
    final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    if (session == null) throw Exception('Session not found: $sessionId');

    final segments = await (_db.select(_db.sessionSegments)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.asc)]))
        .get();

    final segmentBillingList = <SegmentBillingDetails>[];

    for (final segment in segments) {
      final room = await (_db.select(_db.rooms)..where((t) => t.id.equals(segment.roomId))).getSingleOrNull();
      final segmentStart = segment.startedAt;
      final segmentEnd = segment.endedAt ?? now;

      final segDetails = BillingEngine.buildSegmentDetails(
        roomId: segment.roomId,
        roomName: room?.roomName ?? 'Gaming Room',
        equipmentType: room?.equipmentType ?? 'Console',
        startedAt: segmentStart,
        endedAt: segmentEnd,
        hourlyRateSnapshot: segment.hourlyRateSnapshot,
        policy: session.billingPolicy,
      );

      segmentBillingList.add(segDetails);
    }

    return BillingEngine.calculateSessionBreakdown(
      segments: segmentBillingList,
      discount: discount,
      policy: session.billingPolicy,
    );
  }

  /// Ends session with full billing calculation, multi-segment aggregation, cash payment recording,
  /// and returns [SessionReceiptData] for digital receipt generation.
  Future<SessionReceiptData> endSessionWithBilling({
    required String sessionId,
    required String paymentStatus, // PAID or UNPAID
    double discount = 0.0,
    String? notes,
  }) async {
    SessionReceiptData? receiptData;

    await _db.transaction(() async {
      final now = DateTime.now();

      // 1. Fetch Session
      final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      if (session == null) throw Exception('Session not found: $sessionId');

      // 2. Fetch Customer
      final customer = session.customerId != null
          ? await (_db.select(_db.customers)..where((t) => t.id.equals(session.customerId!))).getSingleOrNull()
          : null;

      // 3. Fetch all segments
      final segments = await (_db.select(_db.sessionSegments)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.asc)]))
          .get();

      final segmentBillingList = <SegmentBillingDetails>[];
      int calculatedTotalDurationSeconds = 0;
      String? activeRoomId;

      for (final segment in segments) {
        final room = await (_db.select(_db.rooms)..where((t) => t.id.equals(segment.roomId))).getSingleOrNull();
        final isUnclosed = segment.endedAt == null;
        final segmentStart = segment.startedAt;
        final segmentEnd = isUnclosed ? now : segment.endedAt!;
        final segmentDuration = segmentEnd.difference(segmentStart);
        calculatedTotalDurationSeconds += segmentDuration.inSeconds;

        final segDetails = BillingEngine.buildSegmentDetails(
          roomId: segment.roomId,
          roomName: room?.roomName ?? 'Gaming Room',
          equipmentType: room?.equipmentType ?? 'Console',
          startedAt: segmentStart,
          endedAt: segmentEnd,
          hourlyRateSnapshot: segment.hourlyRateSnapshot,
          policy: session.billingPolicy,
        );

        segmentBillingList.add(segDetails);

        if (isUnclosed) {
          activeRoomId = segment.roomId;
          await (_db.update(_db.sessionSegments)..where((t) => t.id.equals(segment.id))).write(
            SessionSegmentsCompanion(
              endedAt: Value(now),
              amount: Value(segDetails.amount),
            ),
          );
        }
      }

      final breakdown = BillingEngine.calculateSessionBreakdown(
        segments: segmentBillingList,
        discount: discount,
        policy: session.billingPolicy,
      );

      final finalAmount = breakdown.finalAmount;

      // Fetch extensions
      final extensions = await (_db.select(_db.sessionExtensions)
            ..where((t) => t.sessionId.equals(sessionId)))
          .get();
      final totalExtensionMins = extensions.fold<int>(0, (sum, ext) => sum + ext.extensionMinutes);

      // 4. Update Session
      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
        SessionsCompanion(
          status: const Value(AppConstants.sessionCompleted),
          endedAt: Value(now),
          totalDurationSeconds: Value(calculatedTotalDurationSeconds),
          totalAmount: Value(finalAmount),
          paymentStatus: Value(paymentStatus),
        ),
      );

      // 5. Create Payment Record (CASH ONLY)
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

      // 6. Free Room -> AVAILABLE
      if (activeRoomId != null) {
        final roomIdToFree = activeRoomId;
        await (_db.update(_db.rooms)..where((t) => t.id.equals(roomIdToFree))).write(
          RoomsCompanion(
            status: const Value(AppConstants.statusAvailable),
            updatedAt: Value(now),
          ),
        );
      }

      // 7. Log Audit Events
      await _db.into(_db.sessionEvents).insert(
            SessionEventsCompanion(
              id: Value(_uuid.v4()),
              sessionId: Value(sessionId),
              eventType: const Value('ended'),
              eventTimestamp: Value(now),
              newValue: Value('Total: ₹$finalAmount | Subtotal: ₹${breakdown.grossAmount} | Discount: ₹$discount | Status: $paymentStatus (CASH)'),
              notes: Value(notes),
            ),
          );

      receiptData = SessionReceiptData(
        sessionId: sessionId,
        customerName: customer?.name,
        customerPhone: customer?.phone,
        startedAt: session.startedAt,
        endedAt: now,
        totalDuration: Duration(seconds: calculatedTotalDurationSeconds),
        segments: segmentBillingList,
        extensionCount: extensions.length,
        totalExtensionMinutes: totalExtensionMins,
        grossAmount: breakdown.grossAmount,
        discount: discount,
        finalAmount: finalAmount,
        paymentStatus: paymentStatus,
        paymentMethod: AppConstants.methodCash,
        paidAt: isPaid ? now : null,
        notes: notes,
      );
    });

    // Cancel OS alert on session completion
    if (_alarmService != null) {
      await _alarmService.cancelSessionAlert(sessionId);
    }

    return receiptData!;
  }

  Future<void> endSession({
    required String sessionId,
    required String paymentStatus, // PAID or UNPAID
  }) async {
    await endSessionWithBilling(
      sessionId: sessionId,
      paymentStatus: paymentStatus,
    );
  }

  /// Collect outstanding cash for an unpaid session at a later time.
  /// Preserves the historical session start/end timestamps and records the actual collection timestamp.
  Future<void> collectOutstandingCash({
    required String sessionId,
    double? amountCollected,
  }) async {
    await _db.transaction(() async {
      final now = DateTime.now();

      final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      if (session == null) throw Exception('Session not found: $sessionId');

      if (session.paymentStatus == AppConstants.paymentPaid) {
        throw Exception('Session $sessionId is already marked as PAID');
      }

      final payment = await (_db.select(_db.payments)..where((t) => t.sessionId.equals(sessionId))).getSingleOrNull();
      final collected = amountCollected ?? session.totalAmount;

      // Update Session payment status to PAID
      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
        const SessionsCompanion(
          paymentStatus: Value(AppConstants.paymentPaid),
        ),
      );

      // Update Payment record with actual cash collection timestamp
      if (payment != null) {
        await (_db.update(_db.payments)..where((t) => t.id.equals(payment.id))).write(
          PaymentsCompanion(
            amountCollected: Value(collected),
            paymentStatus: const Value(AppConstants.paymentPaid),
            paidAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      } else {
        await _db.into(_db.payments).insert(
          PaymentsCompanion(
            id: Value(_uuid.v4()),
            sessionId: Value(sessionId),
            amountDue: Value(session.totalAmount),
            amountCollected: Value(collected),
            paymentMethod: const Value(AppConstants.methodCash),
            paymentStatus: const Value(AppConstants.paymentPaid),
            paidAt: Value(now),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }

      // Log Audit Event
      await _db.into(_db.sessionEvents).insert(
        SessionEventsCompanion(
          id: Value(_uuid.v4()),
          sessionId: Value(sessionId),
          eventType: const Value('unpaid_settled'),
          eventTimestamp: Value(now),
          oldValue: Value('UNPAID (Due: ₹${session.totalAmount})'),
          newValue: Value('PAID IN CASH: ₹$collected'),
          notes: const Value('Cash debt collected at desk'),
        ),
      );
    });
  }

  /// Rebuilds complete [SessionReceiptData] for any completed session
  Future<SessionReceiptData> getSessionReceiptData(String sessionId) async {
    final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    if (session == null) throw Exception('Session not found: $sessionId');

    final customer = session.customerId != null
        ? await (_db.select(_db.customers)..where((t) => t.id.equals(session.customerId!))).getSingleOrNull()
        : null;

    final payment = await (_db.select(_db.payments)..where((t) => t.sessionId.equals(sessionId))).getSingleOrNull();

    final segments = await (_db.select(_db.sessionSegments)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.asc)]))
        .get();

    final segmentBillingList = <SegmentBillingDetails>[];
    for (final segment in segments) {
      final room = await (_db.select(_db.rooms)..where((t) => t.id.equals(segment.roomId))).getSingleOrNull();
      final segEnd = segment.endedAt ?? session.endedAt ?? DateTime.now();
      segmentBillingList.add(
        BillingEngine.buildSegmentDetails(
          roomId: segment.roomId,
          roomName: room?.roomName ?? 'Gaming Room',
          equipmentType: room?.equipmentType ?? 'Console',
          startedAt: segment.startedAt,
          endedAt: segEnd,
          hourlyRateSnapshot: segment.hourlyRateSnapshot,
          policy: session.billingPolicy,
        ),
      );
    }

    final extensions = await (_db.select(_db.sessionExtensions)..where((t) => t.sessionId.equals(sessionId))).get();
    final totalExtensionMins = extensions.fold<int>(0, (sum, ext) => sum + ext.extensionMinutes);

    final gross = segmentBillingList.fold<double>(0.0, (sum, seg) => sum + seg.amount);
    final discount = (gross - session.totalAmount) > 0 ? (gross - session.totalAmount) : 0.0;

    return SessionReceiptData(
      sessionId: session.id,
      customerName: customer?.name,
      customerPhone: customer?.phone,
      startedAt: session.startedAt,
      endedAt: session.endedAt ?? DateTime.now(),
      totalDuration: Duration(seconds: session.totalDurationSeconds),
      segments: segmentBillingList,
      extensionCount: extensions.length,
      totalExtensionMinutes: totalExtensionMins,
      grossAmount: gross,
      discount: discount,
      finalAmount: session.totalAmount,
      paymentStatus: session.paymentStatus,
      paymentMethod: payment?.paymentMethod ?? AppConstants.methodCash,
      paidAt: payment?.paidAt,
    );
  }

  /// Watch all completed sessions with outstanding UNPAID dues
  Stream<List<UnpaidSessionItem>> watchUnpaidSessions() {
    final query = _db.select(_db.sessions).join([
      leftOuterJoin(_db.customers, _db.customers.id.equalsExp(_db.sessions.customerId)),
    ])..where(_db.sessions.status.equals(AppConstants.sessionCompleted) &
              _db.sessions.paymentStatus.equals(AppConstants.paymentUnpaid))
      ..orderBy([OrderingTerm(expression: _db.sessions.endedAt, mode: OrderingMode.desc)]);

    return query.watch().asyncMap((rows) async {
      final list = <UnpaidSessionItem>[];
      for (final row in rows) {
        final session = row.readTable(_db.sessions);
        final customer = row.readTableOrNull(_db.customers);

        final lastSegment = await (_db.select(_db.sessionSegments)
              ..where((t) => t.sessionId.equals(session.id))
              ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc)])
              ..limit(1))
            .getSingleOrNull();

        Room? room;
        if (lastSegment != null) {
          room = await (_db.select(_db.rooms)..where((t) => t.id.equals(lastSegment.roomId))).getSingleOrNull();
        }

        final payment = await (_db.select(_db.payments)..where((t) => t.sessionId.equals(session.id))).getSingleOrNull();

        if (room != null) {
          list.add(
            UnpaidSessionItem(
              session: session,
              customer: customer,
              room: room,
              payment: payment,
              endedAt: session.endedAt ?? session.scheduledEndAt,
              amountDue: session.totalAmount,
            ),
          );
        }
      }
      return list;
    });
  }

  Future<List<SessionExtension>> getSessionExtensions(String sessionId) {
    return (_db.select(_db.sessionExtensions)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
        .get();
  }

  Future<List<SessionEvent>> getSessionEvents(String sessionId) {
    return (_db.select(_db.sessionEvents)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.eventTimestamp, mode: OrderingMode.asc)]))
        .get();
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

  /// Streams completed sessions for permanent history with multi-faceted filtering
  Stream<List<HistoricalSessionItem>> watchSessionHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? paymentStatus, // ALL, PAID, UNPAID
    String? roomId,
    String? searchQuery,
  }) {
    final query = _db.select(_db.sessions).join([
      leftOuterJoin(_db.customers, _db.customers.id.equalsExp(_db.sessions.customerId)),
    ])..where(_db.sessions.status.equals(AppConstants.sessionCompleted));

    if (startDate != null) {
      query.where(_db.sessions.startedAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where(_db.sessions.startedAt.isSmallerOrEqualValue(endDate));
    }
    if (paymentStatus != null && paymentStatus != 'ALL') {
      query.where(_db.sessions.paymentStatus.equals(paymentStatus));
    }

    query.orderBy([OrderingTerm(expression: _db.sessions.startedAt, mode: OrderingMode.desc)]);

    return query.watch().asyncMap((rows) async {
      final list = <HistoricalSessionItem>[];
      for (final row in rows) {
        final session = row.readTable(_db.sessions);
        final customer = row.readTableOrNull(_db.customers);

        // Fetch segments
        final segments = await (_db.select(_db.sessionSegments)
              ..where((t) => t.sessionId.equals(session.id))
              ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.asc)]))
            .get();

        // Room filter check
        if (roomId != null && !segments.any((s) => s.roomId == roomId)) {
          continue;
        }

        // Search query filter (customer name, customer phone, session ID)
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final q = searchQuery.trim().toLowerCase();
          final matchesId = session.id.toLowerCase().contains(q);
          final matchesCustomer = customer != null &&
              (customer.name.toLowerCase().contains(q) || (customer.phone?.contains(q) ?? false));
          if (!matchesId && !matchesCustomer) {
            continue;
          }
        }

        // Fetch rooms for segments
        final rooms = <Room>[];
        for (final seg in segments) {
          final room = await (_db.select(_db.rooms)..where((t) => t.id.equals(seg.roomId))).getSingleOrNull();
          if (room != null && !rooms.any((r) => r.id == room.id)) {
            rooms.add(room);
          }
        }

        // Fetch payment
        final payment = await (_db.select(_db.payments)..where((t) => t.sessionId.equals(session.id))).getSingleOrNull();

        // Fetch extensions count
        final extensions = await (_db.select(_db.sessionExtensions)..where((t) => t.sessionId.equals(session.id))).get();

        list.add(HistoricalSessionItem(
          session: session,
          customer: customer,
          segments: segments,
          rooms: rooms,
          payment: payment,
          extensionCount: extensions.length,
        ));
      }
      return list;
    });
  }

  /// Builds complete chronological audit timeline for a session
  Future<DetailedSessionTimeline> getSessionTimeline(String sessionId) async {
    final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId))).getSingle();
    final customer = session.customerId != null
        ? await (_db.select(_db.customers)..where((t) => t.id.equals(session.customerId!))).getSingleOrNull()
        : null;

    final segments = await (_db.select(_db.sessionSegments)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.asc)]))
        .get();

    final rooms = <Room>[];
    for (final seg in segments) {
      final room = await (_db.select(_db.rooms)..where((t) => t.id.equals(seg.roomId))).getSingleOrNull();
      if (room != null && !rooms.any((r) => r.id == room.id)) {
        rooms.add(room);
      }
    }

    final payment = await (_db.select(_db.payments)..where((t) => t.sessionId.equals(sessionId))).getSingleOrNull();
    final extensions = await getSessionExtensions(sessionId);
    final events = await getSessionEvents(sessionId);

    final item = HistoricalSessionItem(
      session: session,
      customer: customer,
      segments: segments,
      rooms: rooms,
      payment: payment,
      extensionCount: extensions.length,
    );

    return DetailedSessionTimeline(
      sessionItem: item,
      events: events,
      extensions: extensions,
    );
  }
}
