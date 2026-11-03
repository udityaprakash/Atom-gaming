import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/session_repository.dart';
import '../providers/session_provider.dart';
import 'widgets/end_session_dialog.dart';
import 'widgets/extend_session_sheet.dart';
import 'widgets/transfer_room_dialog.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionsAsync = ref.watch(activeRoomSessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SESSIONS & BILLING',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: activeSessionsAsync.when(
        data: (activeSessions) {
          if (activeSessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_empty, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No Active Sessions',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Start a session from the Dashboard.',
                    style: GoogleFonts.rajdhani(color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: activeSessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final active = activeSessions[index];
              return _buildSessionCard(context, ref, active);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, WidgetRef ref, ActiveRoomSession active) {
    final now = ref.watch(liveTimerTickerProvider).maybeWhen(
          data: (d) => d,
          orElse: () => DateTime.now(),
        );

    final session = active.session;
    final segment = active.segment;
    final isPaused = session.status == AppConstants.sessionPaused;

    final elapsed = now.difference(segment.startedAt);
    final remaining = session.scheduledEndAt.difference(now);
    final isOvertime = remaining.isNegative;

    final elapsedMinutes = elapsed.inSeconds / 60.0;
    final estimatedCharge = ((elapsedMinutes / 60.0) * segment.hourlyRateSnapshot).roundToDouble();

    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderColor: isPaused
          ? AppColors.paused
          : isOvertime
              ? AppColors.occupied
              : AppColors.primaryGlow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                active.room.roomName,
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              StatusBadge(
                status: isPaused
                    ? 'PAUSED'
                    : isOvertime
                        ? 'OVERTIME'
                        : active.session.status,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${active.room.equipmentType} • Customer: ${active.customer?.name ?? "Guest"}',
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(color: AppColors.cardBorder, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('Started', TimeFormatter.formatTime(segment.startedAt)),
              _buildMetric('Scheduled End', TimeFormatter.formatTime(active.session.scheduledEndAt)),
              _buildMetric('Elapsed', TimeFormatter.formatDuration(elapsed)),
              _buildMetric('Est. Bill', CurrencyFormatter.format(estimatedCharge), isHighlighted: true),
            ],
          ),
          const SizedBox(height: 12),

          // Phase 2 Action Buttons: Extend, Transfer, Pause/Resume, End
          Row(
            children: [
              Expanded(
                child: NeonButton(
                  label: 'EXTEND',
                  icon: Icons.more_time,
                  color: AppColors.primary,
                  isOutlined: true,
                  height: 34,
                  fontSize: 11,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ExtendSessionSheet(activeSession: active),
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: NeonButton(
                  label: 'TRANSFER',
                  icon: Icons.swap_horiz,
                  color: AppColors.secondary,
                  isOutlined: true,
                  height: 34,
                  fontSize: 11,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => TransferRoomDialog(activeSession: active),
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: NeonButton(
                  label: isPaused ? 'RESUME' : 'PAUSE',
                  icon: isPaused ? Icons.play_arrow : Icons.pause,
                  color: isPaused ? AppColors.available : AppColors.paused,
                  isOutlined: true,
                  height: 34,
                  fontSize: 11,
                  onPressed: () async {
                    final repo = ref.read(sessionRepositoryProvider);
                    if (isPaused) {
                      await repo.resumeSession(sessionId: session.id);
                    } else {
                      await repo.pauseSession(sessionId: session.id);
                    }
                  },
                ),
              ),
              const SizedBox(width: 6),
              NeonButton(
                label: 'END',
                icon: Icons.stop_circle_outlined,
                color: AppColors.occupied,
                height: 34,
                fontSize: 11,
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => EndSessionDialog(activeSession: active),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, {bool isHighlighted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? AppColors.available : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
