import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../data/session_repository.dart';
import '../../providers/session_provider.dart';

class EndSessionDialog extends ConsumerStatefulWidget {
  final ActiveRoomSession activeSession;

  const EndSessionDialog({super.key, required this.activeSession});

  @override
  ConsumerState<EndSessionDialog> createState() => _EndSessionDialogState();
}

class _EndSessionDialogState extends ConsumerState<EndSessionDialog> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final segment = widget.activeSession.segment;
    final room = widget.activeSession.room;
    final customer = widget.activeSession.customer;

    final elapsed = now.difference(segment.startedAt);
    final elapsedMinutes = elapsed.inSeconds / 60.0;
    final totalAmount = ((elapsedMinutes / 60.0) * segment.hourlyRateSnapshot).roundToDouble();

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
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Room & Customer Info
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
                  _buildDetailRow('Customer', customer?.name ?? 'Guest Customer'),
                  const SizedBox(height: 6),
                  _buildDetailRow('Start Time', TimeFormatter.formatTime(segment.startedAt)),
                  const SizedBox(height: 6),
                  _buildDetailRow('End Time', TimeFormatter.formatTime(now)),
                  const SizedBox(height: 6),
                  _buildDetailRow('Total Duration', TimeFormatter.formatDurationHuman(elapsed)),
                  const SizedBox(height: 6),
                  _buildDetailRow('Rate Snapshot', '${CurrencyFormatter.format(segment.hourlyRateSnapshot)}/hr'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Final Bill Box
            Container(
              padding: const EdgeInsets.all(14),
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
                      const SizedBox(height: 2),
                      Text(
                        'Cash Payment Only',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    CurrencyFormatter.format(totalAmount),
                    style: GoogleFonts.orbitron(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.available,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settlement Options Notice
            Text(
              'Select payment status to close session:',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
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
            const SizedBox(width: 8),

            // Unpaid Button
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => _handleEnd(AppConstants.paymentUnpaid),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.occupied),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
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
            const SizedBox(width: 8),

            // Paid Button
            Expanded(
              flex: 2,
              child: NeonButton(
                label: 'PAID (CASH)',
                icon: Icons.payments,
                color: AppColors.available,
                height: 42,
                fontSize: 12,
                onPressed: _isSubmitting ? null : () => _handleEnd(AppConstants.paymentPaid),
              ),
            ),
          ],
        ),
      ],
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
      await repo.endSession(
        sessionId: widget.activeSession.session.id,
        paymentStatus: paymentStatus,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Session ended for ${widget.activeSession.room.roomName}! Marked as $paymentStatus.',
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
