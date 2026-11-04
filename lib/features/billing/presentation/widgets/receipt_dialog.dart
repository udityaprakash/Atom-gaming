import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/receipt_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../shared/widgets/neon_button.dart';

class ReceiptDialog extends StatefulWidget {
  final SessionReceiptData receiptData;

  const ReceiptDialog({super.key, required this.receiptData});

  @override
  State<ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<ReceiptDialog> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareReceiptImage() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Unable to locate receipt boundary');
      }

      // Render image at 3.0 pixelRatio for crisp print/retina resolution
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to generate PNG image data');
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final isPaid = widget.receiptData.paymentStatus.toUpperCase() == AppConstants.paymentPaid;
      await ReceiptService.shareReceiptAsImage(
        imageBytes: pngBytes,
        sessionId: widget.receiptData.sessionId,
        isPaid: isPaid,
      );
    } catch (e) {
      debugPrint('Error sharing receipt image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share image receipt: $e'),
            backgroundColor: AppColors.occupied,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiptData = widget.receiptData;
    final isPaid = receiptData.paymentStatus.toUpperCase() == AppConstants.paymentPaid;
    final shortId = receiptData.sessionId.length > 8
        ? receiptData.sessionId.substring(0, 8).toUpperCase()
        : receiptData.sessionId.toUpperCase();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
      contentPadding: const EdgeInsets.all(20),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'DIGITAL RECEIPT',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
            onPressed: () => Navigator.pop(context),
            splashRadius: 18,
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Receipt Ticket Card
              RepaintBoundary(
                key: _repaintKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Header
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.sports_esports, color: AppColors.primary, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            ReceiptService.storeName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ReceiptService.storeTagline,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            ReceiptService.storeContact,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.cardBorder, height: 1),
                    const SizedBox(height: 12),

                    // Session Meta
                    _buildMetaRow('SESSION ID', '#$shortId'),
                    const SizedBox(height: 4),
                    _buildMetaRow('DATE & TIME', TimeFormatter.formatTime(receiptData.endedAt)),
                    const SizedBox(height: 4),
                    _buildMetaRow(
                      'CUSTOMER',
                      receiptData.customerName?.isNotEmpty == true
                          ? receiptData.customerName!
                          : 'Walk-in Guest',
                    ),
                    if (receiptData.customerPhone != null && receiptData.customerPhone!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildMetaRow('PHONE', receiptData.customerPhone!),
                    ],
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.cardBorder, height: 1),
                    const SizedBox(height: 12),

                    // Room & Usage Segments
                    Text(
                      'ROOM USAGE BREAKDOWN',
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...receiptData.segments.map((seg) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    seg.roomName,
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(seg.amount),
                                    style: GoogleFonts.orbitron(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${seg.equipmentType} • ${CurrencyFormatter.format(seg.hourlyRateSnapshot)}/hr',
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    TimeFormatter.formatDurationHuman(seg.duration),
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    if (receiptData.extensionCount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Extensions (${receiptData.extensionCount}x)',
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              color: AppColors.endingSoon,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '+${receiptData.totalExtensionMinutes} mins',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              color: AppColors.endingSoon,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 10),
                    const Divider(color: AppColors.cardBorder, height: 1),
                    const SizedBox(height: 10),

                    // Calculations
                    _buildCalculationRow(
                      'Total Duration',
                      TimeFormatter.formatDurationHuman(receiptData.totalDuration),
                    ),
                    const SizedBox(height: 4),
                    _buildCalculationRow('Subtotal', CurrencyFormatter.format(receiptData.grossAmount)),
                    if (receiptData.discount > 0) ...[
                      const SizedBox(height: 4),
                      _buildCalculationRow(
                        'Discount',
                        '-${CurrencyFormatter.format(receiptData.discount)}',
                        isNegative: true,
                      ),
                    ],
                    const SizedBox(height: 10),

                    // Final Total Due Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: (isPaid ? AppColors.available : AppColors.occupied).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (isPaid ? AppColors.available : AppColors.occupied).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL AMOUNT',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                isPaid ? 'CASH COLLECTED' : 'UNPAID DEBT',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isPaid ? AppColors.available : AppColors.occupied,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            CurrencyFormatter.format(receiptData.finalAmount),
                            style: GoogleFonts.orbitron(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isPaid ? AppColors.available : AppColors.occupied,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    // Payment Method Tag
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Text(
                          'Payment Method: CASH ONLY',
                          style: GoogleFonts.rajdhani(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        '🎮 Level Up & Game On! 🚀',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: _isSharing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Icon(Icons.share, size: 16, color: AppColors.primary),
                      label: Text(
                        _isSharing ? 'SHARING...' : 'SHARE',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isSharing ? null : _shareReceiptImage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeonButton(
                      label: 'DONE',
                      icon: Icons.check,
                      color: AppColors.available,
                      height: 42,
                      fontSize: 13,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationRow(String label, String value, {bool isNegative = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isNegative ? AppColors.occupied : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
