import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Rooms,
  Customers,
  Games,
  Sessions,
  SessionSegments,
  SessionExtensions,
  Payments,
  SessionEvents,
  AppSettings,
  Reservations,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(sessions, sessions.controllerCount);
        await m.addColumn(sessionSegments, sessionSegments.controllerCount);
      }
      if (from < 3) {
        await m.createTable(games);
        await m.addColumn(sessions, sessions.gameId);
        await m.addColumn(sessionSegments, sessionSegments.gameId);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'atom.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
