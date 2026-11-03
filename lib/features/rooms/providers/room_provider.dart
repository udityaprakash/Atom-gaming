import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/room_repository.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RoomRepository(db);
});

final allRoomsStreamProvider = StreamProvider<List<Room>>((ref) {
  final repo = ref.watch(roomRepositoryProvider);
  return repo.watchAllRooms();
});

final activeRoomsProvider = Provider<AsyncValue<List<Room>>>((ref) {
  final roomsAsync = ref.watch(allRoomsStreamProvider);
  return roomsAsync.whenData(
    (rooms) => rooms.where((r) => r.status != AppConstants.statusDeactivated).toList(),
  );
});

final availableRoomsProvider = Provider<AsyncValue<List<Room>>>((ref) {
  final roomsAsync = ref.watch(allRoomsStreamProvider);
  return roomsAsync.whenData(
    (rooms) => rooms.where((r) => r.status == AppConstants.statusAvailable).toList(),
  );
});

class RoomFilterNotifier extends Notifier<String> {
  @override
  String build() => 'ALL';
  void setFilter(String filter) => state = filter;
}

final roomFilterProvider = NotifierProvider<RoomFilterNotifier, String>(RoomFilterNotifier.new);

class RoomSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setSearch(String query) => state = query;
}

final roomSearchQueryProvider = NotifierProvider<RoomSearchNotifier, String>(RoomSearchNotifier.new);

final filteredRoomsProvider = Provider<AsyncValue<List<Room>>>((ref) {
  final roomsAsync = ref.watch(activeRoomsProvider);
  final filter = ref.watch(roomFilterProvider);
  final search = ref.watch(roomSearchQueryProvider).toLowerCase();

  return roomsAsync.whenData((rooms) {
    return rooms.where((room) {
      final matchesFilter = switch (filter) {
        'AVAILABLE' => room.status == AppConstants.statusAvailable,
        'OCCUPIED' => room.status == AppConstants.statusOccupied ||
            room.status == AppConstants.statusEndingSoon,
        'MAINTENANCE' => room.status == AppConstants.statusMaintenance,
        'PAUSED' => room.status == AppConstants.statusPaused,
        _ => true,
      };

      final matchesSearch = search.isEmpty ||
          room.roomName.toLowerCase().contains(search) ||
          room.equipmentType.toLowerCase().contains(search);

      return matchesFilter && matchesSearch;
    }).toList();
  });
});
