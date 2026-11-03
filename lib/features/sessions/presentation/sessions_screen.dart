import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/session_repository.dart';
import '../providers/session_provider.dart';

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
                  Icon(Icons.hourglass_empty, size: 48, color: AppColors.textMuted),
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

    final elapsed = now.difference(active.segment.startedAt);
    final remaining = active.session.scheduledEndAt.difference(now);
    final isOvertime = remaining.isNegative;

    final elapsedMinutes = elapsed.inSeconds / 60.0;
    final estimatedCharge = ((elapsedMinutes / 60.0) * active.segment.hourlyRateSnapshot).roundToDouble();

    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderColor: isOvertime ? AppColors.occupied : AppColors.primaryGlow,
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
              StatusBadge(status: isOvertime ? 'OVERTIME' : active.session.status),
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
              _buildMetric('Started', TimeFormatter.formatTime(active.segment.startedAt)),
              _buildMetric('Expected End', TimeFormatter.formatTime(active.session.scheduledEndAt)),
              _buildMetric('Elapsed', TimeFormatter.formatDuration(elapsed)),
              _buildMetric('Est. Bill', CurrencyFormatter.format(estimatedCharge), isHighlighted: true),
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
          style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
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
