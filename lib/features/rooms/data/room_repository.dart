import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';

class RoomRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  RoomRepository(this._db);

  Stream<List<Room>> watchAllRooms() {
    return (_db.select(_db.rooms)
          ..orderBy([
            (t) => OrderingTerm(expression: t.roomName, mode: OrderingMode.asc)
          ]))
        .watch();
  }

  Future<List<Room>> getAllRooms() {
    return (_db.select(_db.rooms)
          ..orderBy([
            (t) => OrderingTerm(expression: t.roomName, mode: OrderingMode.asc)
          ]))
        .get();
  }

  Future<Room?> getRoomById(String id) {
    return (_db.select(_db.rooms)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<String> createRoom({
    required String roomName,
    required String equipmentType,
    required int controllerCount,
    required double hourlyRate,
    String? description,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.into(_db.rooms).insert(
          RoomsCompanion(
            id: Value(id),
            roomName: Value(roomName.trim()),
            equipmentType: Value(equipmentType),
            controllerCount: Value(controllerCount),
            hourlyRate: Value(hourlyRate),
            status: const Value(AppConstants.statusAvailable),
            description: Value(description?.trim()),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return id;
  }

  Future<void> updateRoom({
    required String id,
    required String roomName,
    required String equipmentType,
    required int controllerCount,
    required double hourlyRate,
    String? description,
    String? status,
  }) async {
    final now = DateTime.now();
    await (_db.update(_db.rooms)..where((t) => t.id.equals(id))).write(
      RoomsCompanion(
        roomName: Value(roomName.trim()),
        equipmentType: Value(equipmentType),
        controllerCount: Value(controllerCount),
        hourlyRate: Value(hourlyRate),
        description: Value(description?.trim()),
        status: status != null ? Value(status) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> setRoomStatus(String id, String status) async {
    final now = DateTime.now();
    await (_db.update(_db.rooms)..where((t) => t.id.equals(id))).write(
      RoomsCompanion(
        status: Value(status),
        updatedAt: Value(now),
      ),
    );
  }

  Future<bool> hasDependencies(String roomId) async {
    final segments = await (_db.select(_db.sessionSegments)
          ..where((t) => t.roomId.equals(roomId))
          ..limit(1))
        .get();
    return segments.isNotEmpty;
  }

  Future<bool> deleteRoom(String id) async {
    final hasDeps = await hasDependencies(id);
    if (hasDeps) {
      // Historical dependencies exist; cannot delete.
      return false;
    }
    final deletedCount = await (_db.delete(_db.rooms)..where((t) => t.id.equals(id))).go();
    return deletedCount > 0;
  }
}
