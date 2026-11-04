import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/billing_engine.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../../billing/presentation/widgets/receipt_dialog.dart';
import '../../data/session_repository.dart';
import '../../providers/session_provider.dart';

class EndSessionDialog extends ConsumerStatefulWidget {
  final ActiveRoomSession activeSession;

  const EndSessionDialog({super.key, required this.activeSession});

  @override
  ConsumerState<EndSessionDialog> createState() => _EndSessionDialogState();
}

class _EndSessionDialogState extends ConsumerState<EndSessionDialog> {
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();

  double _discount = 0.0;
  bool _isSubmitting = false;
  SessionBillingBreakdown? _breakdown;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _discountController.addListener(_onDiscountChanged);
    _loadLiveBreakdown();
  }

  @override
  void dispose() {
    _discountController.removeListener(_onDiscountChanged);
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onDiscountChanged() {
    final text = _discountController.text.trim();
    final parsed = double.tryParse(text) ?? 0.0;
    if (parsed != _discount) {
      setState(() {
        _discount = parsed;
      });
    }
  }

  Future<void> _loadLiveBreakdown() async {
    try {
      final repo = ref.read(sessionRepositoryProvider);
      final breakdown = await repo.calculateLiveSessionBreakdown(
        widget.activeSession.session.id,
      );
      if (mounted) {
        setState(() {
          _breakdown = breakdown;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final segment = widget.activeSession.segment;
    final room = widget.activeSession.room;
    final customer = widget.activeSession.customer;

    // Fallback calculation if breakdown isn't loaded yet
    final elapsed = now.difference(segment.startedAt);
    final fallbackAmount = ((elapsed.inSeconds / 3600.0) * segment.hourlyRateSnapshot).roundToDouble();

    final grossAmount = _breakdown?.grossAmount ?? fallbackAmount;
    final finalAmount = (grossAmount - _discount) > 0 ? (grossAmount - _discount).roundToDouble() : 0.0;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
      title: Row(
        children: [
          Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            'END SESSION & BILL',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Customer & Room Summary Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Room', '${room.roomName} (${room.equipmentType})'),
                    const SizedBox(height: 6),
                    _buildDetailRow('Customer', customer?.name ?? 'Walk-in Guest'),
                    if (customer?.phone != null) ...[
                      const SizedBox(height: 6),
                      _buildDetailRow('Phone', customer!.phone!),
                    ],
                    const SizedBox(height: 6),
                    _buildDetailRow('Rate', '${CurrencyFormatter.format(segment.hourlyRateSnapshot)}/hr'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Itemized Room Segments Breakdown
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_breakdown != null && _breakdown!.segments.isNotEmpty) ...[
                Text(
                  'ROOM USAGE BREAKDOWN',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                ...List.generate(_breakdown!.segments.length, (idx) {
                  final seg = _breakdown!.segments[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seg.roomName,
                              style: GoogleFonts.rajdhani(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${TimeFormatter.formatDurationHuman(seg.duration)} • ${CurrencyFormatter.format(seg.hourlyRateSnapshot)}/hr',
                              style: GoogleFonts.rajdhani(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.format(seg.amount),
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 6),
              ],

              // Discount / Adjustment Input Field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _discountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Discount / Promo (₹)',
                        labelStyle: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.discount_outlined, size: 16, color: AppColors.textMuted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _notesController,
                      style: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        labelStyle: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.note_alt_outlined, size: 16, color: AppColors.textMuted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Final Bill Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.available.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.available.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL AMOUNT DUE',
                          style: GoogleFonts.rajdhani(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (_discount > 0)
                          Text(
                            'Subtotal: ${CurrencyFormatter.format(grossAmount)} - ₹$_discount',
                            style: GoogleFonts.rajdhani(
                              fontSize: 10,
                              color: AppColors.occupied,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            'Cash Collection Only',
                            style: GoogleFonts.rajdhani(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.format(finalAmount),
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.available,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // "Other Payment Methods - Coming Soon" (SRS Section 8.4)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'OTHER PAYMENT METHODS – COMING SOON',
                          style: GoogleFonts.rajdhani(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildDisabledMethod('UPI'),
                        _buildDisabledMethod('Card / POS'),
                        _buildDisabledMethod('Net Banking'),
                        _buildDisabledMethod('Wallets'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        Row(
          children: [
            // Cancel Button
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Unpaid Button
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => _handleEnd(AppConstants.paymentUnpaid),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.occupied),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'MARK UNPAID',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.occupied,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Paid Button
            Expanded(
              flex: 2,
              child: NeonButton(
                label: 'PAID (CASH)',
                icon: Icons.payments,
                color: AppColors.available,
                height: 40,
                fontSize: 12,
                onPressed: _isSubmitting ? null : () => _handleEnd(AppConstants.paymentPaid),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisabledMethod(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$title (Soon)',
        style: GoogleFonts.rajdhani(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _handleEnd(String paymentStatus) async {
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      final receiptData = await repo.endSessionWithBilling(
        sessionId: widget.activeSession.session.id,
        paymentStatus: paymentStatus,
        discount: _discount,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context); // Close settlement dialog

        // Show Digital Receipt Dialog right away
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ReceiptDialog(receiptData: receiptData),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Session completed for ${widget.activeSession.room.roomName}! Marked as $paymentStatus.',
            ),
            backgroundColor: paymentStatus == AppConstants.paymentPaid
                ? AppColors.surfaceElevated
                : AppColors.occupied,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
