import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atom/core/constants/app_constants.dart';
import 'package:atom/core/database/app_database.dart';
import 'package:atom/features/rooms/data/room_repository.dart';

void main() {
  late AppDatabase db;
  late RoomRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = RoomRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Creates a new room with available status', () async {
    final roomId = await repository.createRoom(
      roomName: 'Room 01',
      equipmentType: 'PS5',
      controllerCount: 2,
      hourlyRate: 150.0,
      description: '4K Display',
    );

    final room = await repository.getRoomById(roomId);
    expect(room, isNotNull);
    expect(room!.roomName, 'Room 01');
    expect(room.equipmentType, 'PS5');
    expect(room.controllerCount, 2);
    expect(room.hourlyRate, 150.0);
    expect(room.status, AppConstants.statusAvailable);
  });

  test('Updates room details and hourly rate', () async {
    final roomId = await repository.createRoom(
      roomName: 'Room 02',
      equipmentType: 'PS4',
      controllerCount: 2,
      hourlyRate: 100.0,
    );

    await repository.updateRoom(
      id: roomId,
      roomName: 'Room 02 VIP',
      equipmentType: 'PS5',
      controllerCount: 4,
      hourlyRate: 200.0,
      description: 'Upgraded to PS5',
    );

    final updated = await repository.getRoomById(roomId);
    expect(updated!.roomName, 'Room 02 VIP');
    expect(updated.equipmentType, 'PS5');
    expect(updated.controllerCount, 4);
    expect(updated.hourlyRate, 200.0);
    expect(updated.description, 'Upgraded to PS5');
  });

  test('Can toggle room to maintenance and back to available', () async {
    final roomId = await repository.createRoom(
      roomName: 'Room 03',
      equipmentType: 'PC',
      controllerCount: 1,
      hourlyRate: 120.0,
    );

    await repository.setRoomStatus(roomId, AppConstants.statusMaintenance);
    var room = await repository.getRoomById(roomId);
    expect(room!.status, AppConstants.statusMaintenance);

    await repository.setRoomStatus(roomId, AppConstants.statusAvailable);
    room = await repository.getRoomById(roomId);
    expect(room!.status, AppConstants.statusAvailable);
  });

  test('Deletes room with no session dependencies', () async {
    final roomId = await repository.createRoom(
      roomName: 'Room to Delete',
      equipmentType: 'Xbox',
      controllerCount: 2,
      hourlyRate: 110.0,
    );

    final deleted = await repository.deleteRoom(roomId);
    expect(deleted, isTrue);

    final room = await repository.getRoomById(roomId);
    expect(room, isNull);
  });
}
