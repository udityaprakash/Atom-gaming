import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../sessions/data/session_repository.dart';
import '../../../sessions/presentation/widgets/end_session_dialog.dart';
import '../../../sessions/presentation/widgets/start_session_sheet.dart';
import '../../../sessions/providers/session_provider.dart';

class RoomCard extends ConsumerWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionsMap = ref.watch(activeRoomSessionsMapProvider);
    final activeSession = activeSessionsMap[room.id];

    final isAvailable = room.status == AppConstants.statusAvailable;
    final isOccupied = room.status == AppConstants.statusOccupied ||
        room.status == AppConstants.statusEndingSoon;
    final isMaintenance = room.status == AppConstants.statusMaintenance;

    final isOvertime = isOccupied &&
        activeSession != null &&
        DateTime.now().isAfter(activeSession.session.scheduledEndAt);

    final effectiveStatus = isOvertime ? AppConstants.sessionOvertime : room.status;

    Color borderColor = AppColors.cardBorder;
    if (isAvailable) borderColor = AppColors.available.withValues(alpha: 0.4);
    if (isOccupied) borderColor = AppColors.occupied.withValues(alpha: 0.5);
    if (isMaintenance) borderColor = AppColors.maintenance.withValues(alpha: 0.4);

    return GlassCard(
      borderColor: borderColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Room Header: Name alone (availability moved to bottom)
              Text(
                room.roomName,
                style: GoogleFonts.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Equipment & Controller Info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.cardBorder, width: 0.8),
                    ),
                    child: Text(
                      room.equipmentType,
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.gamepad, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 3),
                  Text(
                    '${room.controllerCount}P',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${CurrencyFormatter.format(room.hourlyRate)}/hr',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dynamic Body based on Room State
              if (isAvailable)
                _buildAvailableBody(context)
              else if (isOccupied && activeSession != null)
                _buildOccupiedBody(context, ref, activeSession)
              else if (isMaintenance)
                _buildMaintenanceBody()
              else
                const SizedBox(height: 36),
            ],
          ),

          // Availability moved to the bottom of the card
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: StatusBadge(
              status: effectiveStatus,
              fontSize: 10,
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            label: 'START SESSION',
            icon: Icons.play_arrow,
            color: AppColors.available,
            height: 36,
            fontSize: 12,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => StartSessionSheet(room: room),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOccupiedBody(
    BuildContext context,
    WidgetRef ref,
    ActiveRoomSession active,
  ) {
    // Watch ticker for real-time recalculation
    final now = ref.watch(liveTimerTickerProvider).maybeWhen(
          data: (d) => d,
          orElse: () => DateTime.now(),
        );

    final session = active.session;
    final segment = active.segment;
    final customer = active.customer;

    final elapsed = now.difference(segment.startedAt);
    final remaining = session.scheduledEndAt.difference(now);
    final isOvertime = remaining.isNegative;

    // Estimate bill on the fly: Rate / 60 * elapsed minutes
    final elapsedMinutes = elapsed.inSeconds / 60.0;
    final estimatedAmount = ((elapsedMinutes / 60.0) * segment.hourlyRateSnapshot).roundToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Name
        Row(
          children: [
            const Icon(Icons.person, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                customer?.name ?? 'Guest Customer',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Live Timers Grid
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOvertime
                  ? AppColors.occupied.withValues(alpha: 0.6)
                  : AppColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PLAYED',
                    style: GoogleFonts.rajdhani(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    TimeFormatter.formatDuration(elapsed),
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isOvertime ? 'OVERTIME' : 'REMAINING',
                    style: GoogleFonts.rajdhani(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isOvertime ? AppColors.occupied : AppColors.endingSoon,
                    ),
                  ),
                  Text(
                    isOvertime
                        ? '+${TimeFormatter.formatDuration(remaining.abs())}'
                        : TimeFormatter.formatDuration(remaining),
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isOvertime ? AppColors.occupied : AppColors.endingSoon,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Current Bill Estimate & End Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EST. BILL',
                  style: GoogleFonts.rajdhani(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(estimatedAmount),
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.available,
                  ),
                ),
              ],
            ),
            NeonButton(
              label: 'END',
              icon: Icons.stop_circle_outlined,
              color: AppColors.occupied,
              height: 32,
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
    );
  }

  Widget _buildMaintenanceBody() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.maintenance.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.build, size: 16, color: AppColors.maintenance),
          const SizedBox(height: 4),
          Text(
            'UNDER MAINTENANCE',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.maintenance,
            ),
          ),
        ],
      ),
    );
  }
}
