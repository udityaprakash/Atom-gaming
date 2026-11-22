import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return GameRepository(db);
});

class GameRepository {
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  GameRepository(this._db);

  /// Stream of all games ordered by title
  Stream<List<Game>> watchAllGames({bool activeOnly = false}) {
    final query = _db.select(_db.games);
    if (activeOnly) {
      query.where((t) => t.isActive.equals(true));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.title)]);
    return query.watch();
  }

  /// Get active games snapshot
  Future<List<Game>> getActiveGames() async {
    return (_db.select(_db.games)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  /// Get a single game by ID
  Future<Game?> getGameById(String id) async {
    return (_db.select(_db.games)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Create a new game
  Future<Game> createGame({
    required String title,
    String? platform,
    String? genre,
    required double hourlyRate,
    bool isActive = true,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    final entry = GamesCompanion(
      id: Value(id),
      title: Value(title.trim()),
      platform: Value(platform?.trim().isNotEmpty == true ? platform!.trim() : null),
      genre: Value(genre?.trim().isNotEmpty == true ? genre!.trim() : null),
      hourlyRate: Value(hourlyRate),
      isActive: Value(isActive),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _db.into(_db.games).insert(entry);
    final created = await getGameById(id);
    return created!;
  }

  /// Update an existing game
  Future<void> updateGame({
    required String id,
    String? title,
    String? platform,
    String? genre,
    double? hourlyRate,
    bool? isActive,
  }) async {
    final now = DateTime.now();
    await (_db.update(_db.games)..where((t) => t.id.equals(id))).write(
      GamesCompanion(
        title: title != null ? Value(title.trim()) : const Value.absent(),
        platform: platform != null ? Value(platform.trim().isNotEmpty ? platform.trim() : null) : const Value.absent(),
        genre: genre != null ? Value(genre.trim().isNotEmpty ? genre.trim() : null) : const Value.absent(),
        hourlyRate: hourlyRate != null ? Value(hourlyRate) : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  /// Toggle active state
  Future<void> toggleGameActive(String id, bool currentState) async {
    await updateGame(id: id, isActive: !currentState);
  }

  /// Delete a game permanently
  Future<void> deleteGame(String id) async {
    await (_db.delete(_db.games)..where((t) => t.id.equals(id))).go();
  }
}
