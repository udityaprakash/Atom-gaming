import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../../billing/presentation/widgets/receipt_dialog.dart';
import '../../providers/session_provider.dart';

class SessionTimelineDialog extends ConsumerWidget {
  final String sessionId;

  const SessionTimelineDialog({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(sessionTimelineFamilyProvider(sessionId));

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.history_edu, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'SESSION AUDIT TIMELINE',
                style: GoogleFonts.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: timelineAsync.when(
          data: (timeline) {
            final item = timeline.sessionItem;
            final session = item.session;
            final isPaid = session.paymentStatus == AppConstants.paymentPaid;
            final shortId = session.id.length > 8
                ? session.id.substring(0, 8).toUpperCase()
                : session.id.toUpperCase();

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta summary card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SESSION #$shortId',
                              style: GoogleFonts.orbitron(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isPaid ? AppColors.available : AppColors.occupied)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isPaid ? AppColors.available : AppColors.occupied,
                                ),
                              ),
                              child: Text(
                                session.paymentStatus,
                                style: GoogleFonts.orbitron(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isPaid ? AppColors.available : AppColors.occupied,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Customer: ${item.customer?.name ?? "Walk-in Guest"}',
                          style: GoogleFonts.rajdhani(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Room(s): ${item.roomDisplay}',
                          style: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textMuted),
                        ),
                        Text(
                          'Total Duration: ${TimeFormatter.formatDurationHuman(Duration(seconds: session.totalDurationSeconds))}',
                          style: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Billed: ${CurrencyFormatter.format(session.totalAmount)}',
                              style: GoogleFonts.orbitron(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.available,
                              ),
                            ),
                            if (item.payment?.paidAt != null)
                              Text(
                                'Paid: ${TimeFormatter.formatTime(item.payment!.paidAt!)}',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'CHRONOLOGICAL AUDIT TRAIL',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (timeline.events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'No detailed event log recorded for this session.',
                        style: GoogleFonts.rajdhani(color: AppColors.textMuted),
                      ),
                    )
                  else
                    ...List.generate(timeline.events.length, (idx) {
                      final event = timeline.events[idx];
                      final isLast = idx == timeline.events.length - 1;
                      return _buildTimelineItem(event, isLast);
                    }),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        OutlinedButton.icon(
          icon: const Icon(Icons.receipt_long, size: 16, color: AppColors.primary),
          label: Text('VIEW RECEIPT', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            final repo = ref.read(sessionRepositoryProvider);
            final receipt = await repo.getSessionReceiptData(sessionId);
            if (context.mounted) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => ReceiptDialog(receiptData: receipt),
              );
            }
          },
        ),
        NeonButton(
          label: 'CLOSE',
          icon: Icons.check,
          color: AppColors.surfaceElevated,
          height: 38,
          fontSize: 12,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(dynamic event, bool isLast) {
    IconData icon;
    Color color;

    switch (event.eventType) {
      case 'started':
        icon = Icons.play_circle_fill;
        color = AppColors.available;
        break;
      case 'extended':
        icon = Icons.add_alarm;
        color = AppColors.endingSoon;
        break;
      case 'paused':
        icon = Icons.pause_circle_filled;
        color = AppColors.paused;
        break;
      case 'resumed':
        icon = Icons.play_arrow;
        color = AppColors.available;
        break;
      case 'transferred':
        icon = Icons.swap_horiz;
        color = AppColors.primary;
        break;
      case 'ended':
        icon = Icons.stop_circle;
        color = AppColors.occupied;
        break;
      case 'unpaid_settled':
        icon = Icons.payments;
        color = AppColors.available;
        break;
      default:
        icon = Icons.info;
        color = AppColors.textMuted;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column with Icon and connector line
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Icon(icon, size: 12, color: color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: AppColors.cardBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.eventType.toString().toUpperCase(),
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        TimeFormatter.formatTime(event.eventTimestamp),
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (event.newValue != null && event.newValue!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.newValue!,
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (event.oldValue != null && event.oldValue!.isNotEmpty) ...[
                    Text(
                      'Previous: ${event.oldValue}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  if (event.notes != null && event.notes!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Note: ${event.notes}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
