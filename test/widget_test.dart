import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atom/core/database/app_database.dart';
import 'package:atom/core/database/database_provider.dart';
import 'package:atom/features/sessions/providers/session_provider.dart';
import 'package:atom/main.dart';

void main() {
  testWidgets('AtomApp smoke test', (WidgetTester tester) async {
    final testDb = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(testDb),
          liveTimerTickerProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
        child: const AtomApp(),
      ),
    );

    await tester.pump();
    expect(find.byType(AtomApp), findsOneWidget);

    await testDb.close();
  });
}
