import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';

class DataExportService {
  DataExportService._();

  /// Exports complete SQLite database state into a structured JSON string
  static Future<String> exportAllToJson(AppDatabase db) async {
    final rooms = await db.select(db.rooms).get();
    final customers = await db.select(db.customers).get();
    final sessions = await db.select(db.sessions).get();
    final segments = await db.select(db.sessionSegments).get();
    final extensions = await db.select(db.sessionExtensions).get();
    final payments = await db.select(db.payments).get();
    final events = await db.select(db.sessionEvents).get();
    final reservations = await db.select(db.reservations).get();
    final settings = await db.select(db.appSettings).get();

    final exportMap = {
      'metadata': {
        'appName': 'atom',
        'version': '1.1.0',
        'exportedAt': DateTime.now().toIso8601String(),
      },
      'rooms': rooms.map((r) => {
        'id': r.id,
        'roomName': r.roomName,
        'equipmentType': r.equipmentType,
        'controllerCount': r.controllerCount,
        'hourlyRate': r.hourlyRate,
        'status': r.status,
        'description': r.description,
        'createdAt': r.createdAt.toIso8601String(),
        'updatedAt': r.updatedAt.toIso8601String(),
      }).toList(),
      'customers': customers.map((c) => {
        'id': c.id,
        'name': c.name,
        'phone': c.phone,
        'notes': c.notes,
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt.toIso8601String(),
      }).toList(),
      'sessions': sessions.map((s) => {
        'id': s.id,
        'customerId': s.customerId,
        'status': s.status,
        'startedAt': s.startedAt.toIso8601String(),
        'scheduledEndAt': s.scheduledEndAt.toIso8601String(),
        'endedAt': s.endedAt?.toIso8601String(),
        'billingPolicy': s.billingPolicy,
        'totalDurationSeconds': s.totalDurationSeconds,
        'totalAmount': s.totalAmount,
        'paymentStatus': s.paymentStatus,
        'createdAt': s.createdAt.toIso8601String(),
      }).toList(),
      'sessionSegments': segments.map((seg) => {
        'id': seg.id,
        'sessionId': seg.sessionId,
        'roomId': seg.roomId,
        'startedAt': seg.startedAt.toIso8601String(),
        'endedAt': seg.endedAt?.toIso8601String(),
        'hourlyRateSnapshot': seg.hourlyRateSnapshot,
        'amount': seg.amount,
      }).toList(),
      'sessionExtensions': extensions.map((e) => {
        'id': e.id,
        'sessionId': e.sessionId,
        'previousEndTime': e.previousEndTime.toIso8601String(),
        'newEndTime': e.newEndTime.toIso8601String(),
        'extensionMinutes': e.extensionMinutes,
        'createdAt': e.createdAt.toIso8601String(),
      }).toList(),
      'payments': payments.map((p) => {
        'id': p.id,
        'sessionId': p.sessionId,
        'amountDue': p.amountDue,
        'amountCollected': p.amountCollected,
        'paymentMethod': p.paymentMethod,
        'paymentStatus': p.paymentStatus,
        'paidAt': p.paidAt?.toIso8601String(),
        'createdAt': p.createdAt.toIso8601String(),
        'updatedAt': p.updatedAt.toIso8601String(),
      }).toList(),
      'sessionEvents': events.map((ev) => {
        'id': ev.id,
        'sessionId': ev.sessionId,
        'eventType': ev.eventType,
        'eventTimestamp': ev.eventTimestamp.toIso8601String(),
        'oldValue': ev.oldValue,
        'newValue': ev.newValue,
        'notes': ev.notes,
      }).toList(),
      'reservations': reservations.map((res) => {
        'id': res.id,
        'roomId': res.roomId,
        'customerName': res.customerName,
        'customerPhone': res.customerPhone,
        'reservedFor': res.reservedFor.toIso8601String(),
        'durationMinutes': res.durationMinutes,
        'status': res.status,
        'notes': res.notes,
        'createdAt': res.createdAt.toIso8601String(),
      }).toList(),
      'settings': settings.map((st) => {
        'key': st.key,
        'value': st.value,
        'updatedAt': st.updatedAt.toIso8601String(),
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  /// Exports sessions list to CSV format
  static Future<String> exportSessionsToCsv(AppDatabase db) async {
    final sessions = await db.select(db.sessions).get();
    final customers = await db.select(db.customers).get();
    final customerMap = {for (var c in customers) c.id: c.name};

    final buffer = StringBuffer();
    buffer.writeln('Session ID,Customer ID,Customer Name,Status,Started At,Ended At,Duration (mins),Total Amount (INR),Payment Status,Billing Policy');

    final df = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (final s in sessions) {
      final custName = s.customerId != null ? (customerMap[s.customerId] ?? 'Unknown') : 'Guest';
      final durationMins = (s.totalDurationSeconds / 60.0).toStringAsFixed(1);
      final startedStr = df.format(s.startedAt);
      final endedStr = s.endedAt != null ? df.format(s.endedAt!) : '';

      buffer.writeln(
        '${_escapeCsv(s.id)},${_escapeCsv(s.customerId)},${_escapeCsv(custName)},'
        '${_escapeCsv(s.status)},$startedStr,$endedStr,$durationMins,'
        '${s.totalAmount},${_escapeCsv(s.paymentStatus)},${_escapeCsv(s.billingPolicy)}',
      );
    }

    return buffer.toString();
  }

  /// Exports payments cash collection ledger to CSV format
  static Future<String> exportPaymentsToCsv(AppDatabase db) async {
    final payments = await db.select(db.payments).get();
    final df = DateFormat('yyyy-MM-dd HH:mm:ss');

    final buffer = StringBuffer();
    buffer.writeln('Payment ID,Session ID,Amount Due (INR),Amount Collected (INR),Payment Method,Payment Status,Paid At,Created At');

    for (final p in payments) {
      final paidAtStr = p.paidAt != null ? df.format(p.paidAt!) : '';
      final createdStr = df.format(p.createdAt);

      buffer.writeln(
        '${_escapeCsv(p.id)},${_escapeCsv(p.sessionId)},${p.amountDue},${p.amountCollected},'
        '${_escapeCsv(p.paymentMethod)},${_escapeCsv(p.paymentStatus)},$paidAtStr,$createdStr',
      );
    }

    return buffer.toString();
  }

  /// Exports customer directory to CSV format
  static Future<String> exportCustomersToCsv(AppDatabase db) async {
    final customers = await db.select(db.customers).get();
    final df = DateFormat('yyyy-MM-dd HH:mm:ss');

    final buffer = StringBuffer();
    buffer.writeln('Customer ID,Name,Phone,Notes,Created At');

    for (final c in customers) {
      final createdStr = df.format(c.createdAt);
      buffer.writeln(
        '${_escapeCsv(c.id)},${_escapeCsv(c.name)},${_escapeCsv(c.phone)},${_escapeCsv(c.notes)},$createdStr',
      );
    }

    return buffer.toString();
  }

  /// Saves the export string to a temporary file and triggers the native share sheet
  static Future<void> saveAndShare({
    required String content,
    required String fileName,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'atom Export: $fileName',
      ),
    );
  }

  static String _escapeCsv(String? value) {
    if (value == null) return '';
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
