import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';

class ReservationWithRoom {
  final Reservation reservation;
  final Room room;

  const ReservationWithRoom({
    required this.reservation,
    required this.room,
  });
}

class ReservationRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  ReservationRepository(this._db);

  /// Streams upcoming confirmed reservations joined with room details
  Stream<List<ReservationWithRoom>> watchUpcomingReservations() {
    final now = DateTime.now().subtract(const Duration(hours: 1));
    final query = _db.select(_db.reservations).join([
      innerJoin(_db.rooms, _db.rooms.id.equalsExp(_db.reservations.roomId)),
    ])..where(_db.reservations.status.equals('CONFIRMED') &
              _db.reservations.reservedFor.isBiggerOrEqualValue(now))
      ..orderBy([OrderingTerm(expression: _db.reservations.reservedFor, mode: OrderingMode.asc)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReservationWithRoom(
          reservation: row.readTable(_db.reservations),
          room: row.readTable(_db.rooms),
        );
      }).toList();
    });
  }

  /// Creates an advance reservation with automatic conflict detection
  Future<String> createReservation({
    required String roomId,
    required String customerName,
    String? customerPhone,
    required DateTime reservedFor,
    required int durationMinutes,
    String? notes,
  }) async {
    // 1. Check Room exists and is not permanently deactivated
    final room = await (_db.select(_db.rooms)..where((t) => t.id.equals(roomId))).getSingleOrNull();
    if (room == null) throw Exception('Room not found');
    if (room.status == AppConstants.statusDeactivated) {
      throw Exception('Cannot reserve a deactivated room');
    }

    final newStart = reservedFor;
    final newEnd = reservedFor.add(Duration(minutes: durationMinutes));

    // 2. Conflict Detection: Query existing confirmed reservations on same room
    final existingReservations = await (_db.select(_db.reservations)
          ..where((t) => t.roomId.equals(roomId) & t.status.equals('CONFIRMED')))
        .get();

    for (final ex in existingReservations) {
      final exStart = ex.reservedFor;
      final exEnd = ex.reservedFor.add(Duration(minutes: ex.durationMinutes));

      final hasOverlap = newStart.isBefore(exEnd) && newEnd.isAfter(exStart);
      if (hasOverlap) {
        throw Exception(
          'Reservation conflict: "${room.roomName}" is already booked from '
          '${exStart.hour}:${exStart.minute.toString().padLeft(2, '0')} to '
          '${exEnd.hour}:${exEnd.minute.toString().padLeft(2, '0')}.',
        );
      }
    }

    // 3. Insert Reservation
    final id = _uuid.v4();
    await _db.into(_db.reservations).insert(
          ReservationsCompanion(
            id: Value(id),
            roomId: Value(roomId),
            customerName: Value(customerName.trim()),
            customerPhone: Value(customerPhone?.trim()),
            reservedFor: Value(reservedFor),
            durationMinutes: Value(durationMinutes),
            status: const Value('CONFIRMED'),
            notes: Value(notes?.trim()),
            createdAt: Value(DateTime.now()),
          ),
        );

    return id;
  }

  Future<void> cancelReservation(String reservationId) async {
    await (_db.update(_db.reservations)..where((t) => t.id.equals(reservationId))).write(
      const ReservationsCompanion(status: Value('CANCELLED')),
    );
  }

  Future<void> completeReservation(String reservationId) async {
    await (_db.update(_db.reservations)..where((t) => t.id.equals(reservationId))).write(
      const ReservationsCompanion(status: Value('COMPLETED')),
    );
  }
}
