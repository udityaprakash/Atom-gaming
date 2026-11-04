import 'dart:convert';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atom/core/constants/app_constants.dart';
import 'package:atom/core/database/app_database.dart';
import 'package:atom/core/services/data_export_service.dart';
import 'package:atom/core/services/security_service.dart';
import 'package:atom/features/reservations/data/reservation_repository.dart';
import 'package:atom/features/rooms/data/room_repository.dart';

void main() {
  late AppDatabase db;
  late RoomRepository roomRepo;
  late ReservationRepository reservationRepo;
  late SecurityService securityService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    roomRepo = RoomRepository(db);
    reservationRepo = ReservationRepository(db);
    securityService = SecurityService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Room Maintenance Tests', () {
    test('Mark room as maintenance and restore availability', () async {
      final roomId = await roomRepo.createRoom(
        roomName: 'VR Booth 01',
        equipmentType: 'VR Headset',
        controllerCount: 2,
        hourlyRate: 350.0,
      );

      var room = await (db.select(db.rooms)..where((t) => t.id.equals(roomId))).getSingle();
      expect(room.status, AppConstants.statusAvailable);

      // Mark under maintenance
      await roomRepo.markRoomMaintenance(
        roomId: roomId,
        reasonNotes: 'Replacing lens protectors and firmware update',
      );

      room = await (db.select(db.rooms)..where((t) => t.id.equals(roomId))).getSingle();
      expect(room.status, AppConstants.statusMaintenance);
      expect(room.description, contains('Replacing lens protectors'));

      // Restore availability
      await roomRepo.restoreRoomAvailability(roomId);
      room = await (db.select(db.rooms)..where((t) => t.id.equals(roomId))).getSingle();
      expect(room.status, AppConstants.statusAvailable);
    });
  });

  group('Advance Reservations & Conflict Detection Tests', () {
    test('Successfully book reservation when room has no conflict', () async {
      final roomId = await roomRepo.createRoom(
        roomName: 'PS5 Elite 1',
        equipmentType: 'PS5',
        controllerCount: 2,
        hourlyRate: 200.0,
      );

      final bookingTime = DateTime.now().add(const Duration(hours: 3));
      final resId = await reservationRepo.createReservation(
        roomId: roomId,
        customerName: 'Aarav Patel',
        customerPhone: '9876543210',
        reservedFor: bookingTime,
        durationMinutes: 60,
        notes: 'Birthday tournament',
      );

      expect(resId, isNotEmpty);
      final booking = await (db.select(db.reservations)..where((t) => t.id.equals(resId))).getSingle();
      expect(booking.customerName, 'Aarav Patel');
      expect(booking.status, 'CONFIRMED');
      expect(booking.durationMinutes, 60);
    });

    test('Conflict detection blocks overlapping reservation on same room', () async {
      final roomId = await roomRepo.createRoom(
        roomName: 'Xbox Series X 01',
        equipmentType: 'Xbox Series X',
        controllerCount: 4,
        hourlyRate: 250.0,
      );

      final baseTime = DateTime.now().add(const Duration(hours: 4));
      // First reservation: 4:00 PM to 5:00 PM (60 mins)
      await reservationRepo.createReservation(
        roomId: roomId,
        customerName: 'Gamer 1',
        reservedFor: baseTime,
        durationMinutes: 60,
      );

      // Overlapping reservation attempt: 4:30 PM to 5:30 PM (30 min overlap)
      final overlappingTime = baseTime.add(const Duration(minutes: 30));
      expect(
        () async => await reservationRepo.createReservation(
          roomId: roomId,
          customerName: 'Gamer 2',
          reservedFor: overlappingTime,
          durationMinutes: 60,
        ),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Reservation conflict'))),
      );

      // Non-overlapping reservation after first reservation finishes: 5:00 PM to 6:00 PM
      final nonOverlappingTime = baseTime.add(const Duration(minutes: 60));
      final secondResId = await reservationRepo.createReservation(
        roomId: roomId,
        customerName: 'Gamer 3',
        reservedFor: nonOverlappingTime,
        durationMinutes: 60,
      );
      expect(secondResId, isNotEmpty);
    });

    test('Cancel and complete reservation transitions status', () async {
      final roomId = await roomRepo.createRoom(
        roomName: 'PC Master 01',
        equipmentType: 'Gaming PC',
        controllerCount: 1,
        hourlyRate: 150.0,
      );

      final bookingTime = DateTime.now().add(const Duration(hours: 2));
      final resId = await reservationRepo.createReservation(
        roomId: roomId,
        customerName: 'Rohan Sharma',
        reservedFor: bookingTime,
        durationMinutes: 90,
      );

      await reservationRepo.completeReservation(resId);
      var booking = await (db.select(db.reservations)..where((t) => t.id.equals(resId))).getSingle();
      expect(booking.status, 'COMPLETED');

      await reservationRepo.cancelReservation(resId);
      booking = await (db.select(db.reservations)..where((t) => t.id.equals(resId))).getSingle();
      expect(booking.status, 'CANCELLED');
    });
  });

  group('Security Service PIN Tests', () {
    test('Default state has no PIN enabled', () async {
      final isEnabled = await securityService.isPinEnabled();
      expect(isEnabled, isFalse);

      // Any PIN or empty string passes when no PIN is set
      final verified = await securityService.verifyPin('1234');
      expect(verified, isTrue);
    });

    test('Set, verify, and disable Security PIN', () async {
      // Set new PIN '9876'
      await securityService.setPin('9876');
      expect(await securityService.isPinEnabled(), isTrue);

      // Verify correct PIN
      expect(await securityService.verifyPin('9876'), isTrue);

      // Verify wrong PIN
      expect(await securityService.verifyPin('0000'), isFalse);
      expect(await securityService.verifyPin('9875'), isFalse);

      // Disable PIN with correct current PIN
      final disabled = await securityService.disablePin('9876');
      expect(disabled, isTrue);
      expect(await securityService.isPinEnabled(), isFalse);
    });
  });

  group('Data Export Service Tests', () {
    test('JSON database export generates valid schema structure', () async {
      await roomRepo.createRoom(
        roomName: 'Room Test Export',
        equipmentType: 'PS5',
        controllerCount: 2,
        hourlyRate: 180.0,
      );

      final jsonStr = await DataExportService.exportAllToJson(db);
      expect(jsonStr, isNotEmpty);

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded.containsKey('metadata'), isTrue);
      expect(decoded['metadata']['appName'], 'atom');
      expect(decoded['metadata']['version'], '1.1.0');
      expect(decoded.containsKey('rooms'), isTrue);
      expect((decoded['rooms'] as List).isNotEmpty, isTrue);
      expect(decoded.containsKey('sessions'), isTrue);
      expect(decoded.containsKey('payments'), isTrue);
      expect(decoded.containsKey('customers'), isTrue);
    });

    test('CSV exports generate valid RFC-style headers', () async {
      final sessionsCsv = await DataExportService.exportSessionsToCsv(db);
      expect(sessionsCsv.startsWith('Session ID,Customer Name'), isTrue);

      final paymentsCsv = await DataExportService.exportPaymentsToCsv(db);
      expect(paymentsCsv.startsWith('Payment ID,Session ID'), isTrue);

      final customersCsv = await DataExportService.exportCustomersToCsv(db);
      expect(customersCsv.startsWith('Customer ID,Name,Phone'), isTrue);
    });
  });
}
