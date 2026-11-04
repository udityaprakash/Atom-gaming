import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/currency_formatter.dart';
import '../utils/time_formatter.dart';
import 'billing_engine.dart';

class SessionReceiptData {
  final String sessionId;
  final String? customerName;
  final String? customerPhone;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration totalDuration;
  final List<SegmentBillingDetails> segments;
  final int extensionCount;
  final int totalExtensionMinutes;
  final double grossAmount;
  final double discount;
  final double finalAmount;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime? paidAt;
  final String? notes;

  const SessionReceiptData({
    required this.sessionId,
    this.customerName,
    this.customerPhone,
    required this.startedAt,
    required this.endedAt,
    required this.totalDuration,
    required this.segments,
    this.extensionCount = 0,
    this.totalExtensionMinutes = 0,
    required this.grossAmount,
    this.discount = 0.0,
    required this.finalAmount,
    required this.paymentStatus,
    this.paymentMethod = 'CASH',
    this.paidAt,
    this.notes,
  });
}

class ReceiptService {
  ReceiptService._();

  static const String storeName = 'ATOM GAMING LOUNGE';
  static const String storeTagline = 'Ultimate Console & VR Gaming Experience';
  static const String storeAddress = 'Shop #4, Level 1, Metro City Mall';
  static const String storeContact = '+91 98765 43210';

  /// Generates a clean, monospaced plain-text receipt suitable for SMS, WhatsApp, and thermal printing
  static String formatReceiptText(
    SessionReceiptData data, {
    String? customStoreName,
    String? customStoreAddress,
    String? customStoreContact,
    String? customFooterMessage,
  }) {
    final effectiveStoreName = customStoreName?.trim().isNotEmpty == true ? customStoreName!.trim() : storeName;
    final effectiveAddress = customStoreAddress?.trim().isNotEmpty == true ? customStoreAddress!.trim() : storeAddress;
    final effectiveContact = customStoreContact?.trim().isNotEmpty == true ? customStoreContact!.trim() : storeContact;

    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');
    final timeOnlyFormatter = DateFormat('hh:mm a');
    final shortId = data.sessionId.length > 8
        ? data.sessionId.substring(0, 8).toUpperCase()
        : data.sessionId.toUpperCase();

    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('         $effectiveStoreName');
    buffer.writeln('    $storeTagline');
    buffer.writeln('       $effectiveAddress');
    buffer.writeln('          Ph: $effectiveContact');
    buffer.writeln('========================================');
    buffer.writeln('RECEIPT / CASH INVOICE');
    buffer.writeln('Session ID : #$shortId');
    buffer.writeln('Date       : ${dateFormatter.format(data.endedAt)}');
    buffer.writeln('Customer   : ${data.customerName?.isNotEmpty == true ? data.customerName : "Walk-in Guest"}');
    if (data.customerPhone != null && data.customerPhone!.isNotEmpty) {
      buffer.writeln('Phone      : ${data.customerPhone}');
    }
    buffer.writeln('----------------------------------------');
    buffer.writeln('ROOM & SESSION BREAKDOWN:');

    for (int i = 0; i < data.segments.length; i++) {
      final seg = data.segments[i];
      final segTime = '${timeOnlyFormatter.format(seg.startedAt)} - ${timeOnlyFormatter.format(seg.endedAt)}';
      final durationStr = TimeFormatter.formatDurationHuman(seg.duration);

      buffer.writeln('${i + 1}. ${seg.roomName} [${seg.equipmentType}]');
      buffer.writeln('   Time   : $segTime ($durationStr)');
      buffer.writeln('   Rate   : ${CurrencyFormatter.format(seg.hourlyRateSnapshot)}/hr');
      buffer.writeln('   Amount : ${CurrencyFormatter.format(seg.amount)}');
    }

    if (data.extensionCount > 0) {
      buffer.writeln('----------------------------------------');
      buffer.writeln('Extensions : ${data.extensionCount} (+${data.totalExtensionMinutes} mins)');
    }

    buffer.writeln('----------------------------------------');
    buffer.writeln('Total Duration : ${TimeFormatter.formatDurationHuman(data.totalDuration)}');
    buffer.writeln('Subtotal       : ${CurrencyFormatter.format(data.grossAmount)}');

    if (data.discount > 0) {
      buffer.writeln('Discount       : -${CurrencyFormatter.format(data.discount)}');
    }

    buffer.writeln('----------------------------------------');
    buffer.writeln('TOTAL PAYABLE  : ${CurrencyFormatter.format(data.finalAmount)}');
    buffer.writeln('PAYMENT METHOD : ${data.paymentMethod} (CASH ONLY)');

    final isPaid = data.paymentStatus.toUpperCase() == 'PAID';
    if (isPaid) {
      buffer.writeln('PAYMENT STATUS : PAID IN FULL (CASH)');
      if (data.paidAt != null) {
        buffer.writeln('Cash Paid At   : ${dateFormatter.format(data.paidAt!)}');
      }
    } else {
      buffer.writeln('PAYMENT STATUS : UNPAID (PENDING DEBT)');
      buffer.writeln('BALANCE DUE    : ${CurrencyFormatter.format(data.finalAmount)}');
      buffer.writeln('** Please settle outstanding cash at desk **');
    }

    if (data.notes != null && data.notes!.isNotEmpty) {
      buffer.writeln('Notes          : ${data.notes}');
    }

    final effectiveFooter = customFooterMessage?.trim().isNotEmpty == true
        ? customFooterMessage!.trim()
        : 'Thank you for playing with us!\n          Level Up & Game On!';

    buffer.writeln('========================================');
    buffer.writeln('      $effectiveFooter');
    buffer.writeln('========================================');

    return buffer.toString();
  }

  /// Triggers the native platform share sheet using share_plus
  static Future<void> shareReceipt(
    SessionReceiptData data, {
    String? customStoreName,
    String? customStoreAddress,
    String? customStoreContact,
    String? customFooterMessage,
  }) async {
    final text = formatReceiptText(
      data,
      customStoreName: customStoreName,
      customStoreAddress: customStoreAddress,
      customStoreContact: customStoreContact,
      customFooterMessage: customFooterMessage,
    );
    final shortId = data.sessionId.length > 8
        ? data.sessionId.substring(0, 8).toUpperCase()
        : data.sessionId.toUpperCase();

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'atom Gaming Receipt #$shortId',
      ),
    );
  }
}
