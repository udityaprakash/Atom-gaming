import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/database/database_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/alarm_service.dart';
import 'core/services/recovery_service.dart';
import 'core/theme/app_theme.dart';
import 'features/rooms/data/room_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  // Check and seed initial sample rooms from SRS Section 3.1 if empty
  await _seedInitialRoomsIfEmpty(container);

  // Phase 2: Initialize Alarm Service & Recover active sessions on startup
  final alarmService = container.read(alarmServiceProvider);
  await alarmService.initialize();

  final recoveryService = RecoveryService(
    container.read(appDatabaseProvider),
    alarmService,
  );
  await recoveryService.recoverActiveSessions();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AtomApp(),
    ),
  );
}

Future<void> _seedInitialRoomsIfEmpty(ProviderContainer container) async {
  try {
    final db = container.read(appDatabaseProvider);
    final repo = RoomRepository(db);
    final existingRooms = await repo.getAllRooms();

    if (existingRooms.isEmpty) {
      // Seed default rooms from SRS Section 3.1
      await repo.createRoom(
        roomName: 'Room 01',
        equipmentType: 'PS5',
        controllerCount: 2,
        hourlyRate: 150.0,
        description: 'Sony PlayStation 5 with 2 DualSense controllers & 4K OLED display',
      );
      await repo.createRoom(
        roomName: 'Room 02',
        equipmentType: 'PS5',
        controllerCount: 4,
        hourlyRate: 200.0,
        description: 'Sony PlayStation 5 with 4 DualSense controllers for multiplayer',
      );
      await repo.createRoom(
        roomName: 'Room 03',
        equipmentType: 'PS4',
        controllerCount: 2,
        hourlyRate: 100.0,
        description: 'Sony PlayStation 4 Pro with 2 DualShock 4 controllers',
      );
      await repo.createRoom(
        roomName: 'Room 04',
        equipmentType: 'Gaming PC',
        controllerCount: 1,
        hourlyRate: 120.0,
        description: 'Custom Gaming Rig: RTX 4070, 240Hz monitor & mechanical peripherals',
      );
    }
  } catch (e) {
    debugPrint('Initial seeding error: $e');
  }
}

class AtomApp extends StatelessWidget {
  const AtomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
