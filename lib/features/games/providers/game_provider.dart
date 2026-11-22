import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../data/game_repository.dart';

export '../data/game_repository.dart';

/// Stream provider for all games (including inactive)
final allGamesStreamProvider = StreamProvider<List<Game>>((ref) {
  final repo = ref.watch(gameRepositoryProvider);
  return repo.watchAllGames(activeOnly: false);
});

/// Stream provider for active games only (for dropdowns and start session)
final activeGamesStreamProvider = StreamProvider<List<Game>>((ref) {
  final repo = ref.watch(gameRepositoryProvider);
  return repo.watchAllGames(activeOnly: true);
});

/// Platform filter state provider for the Games Catalog screen
class GamePlatformFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setPlatform(String platform) => state = platform;
}

final gamePlatformFilterProvider =
    NotifierProvider<GamePlatformFilterNotifier, String>(GamePlatformFilterNotifier.new);
