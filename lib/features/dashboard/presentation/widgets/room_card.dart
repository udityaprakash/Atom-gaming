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
import '../../../rooms/providers/room_provider.dart';
import '../../../sessions/data/session_repository.dart';
import '../../../sessions/presentation/widgets/end_session_dialog.dart';
import '../../../sessions/presentation/widgets/extend_session_sheet.dart';
import '../../../sessions/presentation/widgets/start_session_sheet.dart';
import '../../../sessions/presentation/widgets/transfer_room_dialog.dart';
import '../../../sessions/presentation/widgets/change_game_dialog.dart';
import '../../../sessions/providers/session_provider.dart';
import '../../../../core/services/receipt_service.dart';

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
    final isPaused = room.status == AppConstants.statusPaused;
    final isMaintenance = room.status == AppConstants.statusMaintenance;

    Color borderColor = AppColors.cardBorder;
    if (isAvailable) borderColor = AppColors.available.withValues(alpha: 0.4);
    if (isOccupied) borderColor = AppColors.occupied.withValues(alpha: 0.5);
    if (isPaused) borderColor = AppColors.paused.withValues(alpha: 0.6);
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
              // Room Header: Status Dot & Name
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppColors.available
                          : (isPaused
                              ? AppColors.paused
                              : (isMaintenance ? AppColors.maintenance : AppColors.occupied)),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isAvailable
                                  ? AppColors.available
                                  : (isPaused
                                      ? AppColors.paused
                                      : (isMaintenance ? AppColors.maintenance : AppColors.occupied)))
                              .withValues(alpha: 0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      room.roomName,
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
              else if ((isOccupied || isPaused) && activeSession != null)
                _buildOccupiedBody(context, ref, activeSession)
              else if (isMaintenance)
                _buildMaintenanceBody(ref)
              else
                const SizedBox(height: 36),
            ],
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
    final now = ref.watch(liveTimerTickerProvider).maybeWhen(
          data: (d) => d,
          orElse: () => DateTime.now(),
        );

    final session = active.session;
    final segment = active.segment;
    final customer = active.customer;
    final isPaused = session.status == AppConstants.sessionPaused;

    // Freeze elapsed time and billing when paused or when scheduled duration is reached (unless Freeplay is enabled)
    DateTime effectiveTime = now;
    if (isPaused && active.lastPauseTime != null) {
      effectiveTime = active.lastPauseTime!;
    } else if (!active.isFreeplay && now.isAfter(session.scheduledEndAt)) {
      effectiveTime = session.scheduledEndAt;
    }

    final elapsed = (isPaused && active.lastPauseTime != null ? active.lastPauseTime! : now).difference(segment.startedAt);
    final remaining = session.scheduledEndAt.difference(now);
    final isOvertime = remaining.isNegative;

    final effectiveElapsed = effectiveTime.difference(segment.startedAt);
    final elapsedMinutes = (effectiveElapsed.inSeconds > 0 ? effectiveElapsed.inSeconds : 0) / 60.0;
    final estimatedAmount = ((elapsedMinutes / 60.0) * segment.hourlyRateSnapshot).roundToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Game played & Controller Count Pill (Tap to Change Game)
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ChangeGameDialog(activeSession: active),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: active.game != null
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: active.game != null
                            ? AppColors.accent.withValues(alpha: 0.4)
                            : AppColors.cardBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sports_esports,
                          size: 11,
                          color: active.game != null ? AppColors.accent : AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            active.game != null ? active.game!.title : 'Room Rate',
                            style: GoogleFonts.orbitron(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: active.game != null ? AppColors.accent : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.edit, size: 9, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 0.8),
                ),
                child: Text(
                  ReceiptService.formatPlayerCount(session.controllerCount).toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

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
              color: isPaused
                  ? AppColors.paused.withValues(alpha: 0.6)
                  : isOvertime
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
                    isPaused ? 'STATUS' : 'PLAYED',
                    style: GoogleFonts.rajdhani(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    isPaused ? 'PAUSED' : TimeFormatter.formatDuration(elapsed),
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPaused ? AppColors.paused : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isPaused
                        ? 'HOLD'
                        : isOvertime
                            ? 'OVERTIME'
                            : 'REMAINING',
                    style: GoogleFonts.rajdhani(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isPaused
                          ? AppColors.paused
                          : isOvertime
                              ? AppColors.occupied
                              : AppColors.endingSoon,
                    ),
                  ),
                  Text(
                    isPaused
                        ? 'ON PAUSE'
                        : isOvertime
                            ? '+${TimeFormatter.formatDuration(remaining.abs())}'
                            : TimeFormatter.formatDuration(remaining),
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPaused
                          ? AppColors.paused
                          : isOvertime
                              ? AppColors.occupied
                              : AppColors.endingSoon,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Est. Bill & End Button
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
              height: 30,
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
        const SizedBox(height: 6),

        // Phase 2 Advanced Controls: 2 Rows x 2 Columns layout
        Column(
          children: [
            Row(
              children: [
                // Quick Extend
                Expanded(
                  child: _buildSmallAction(
                    label: 'EXTEND',
                    icon: Icons.more_time,
                    color: AppColors.primary,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ExtendSessionSheet(activeSession: active),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 5),

                // Quick Transfer
                Expanded(
                  child: _buildSmallAction(
                    label: 'MOVE',
                    icon: Icons.swap_horiz,
                    color: AppColors.secondary,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => TransferRoomDialog(activeSession: active),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                // Change Game
                Expanded(
                  child: _buildSmallAction(
                    label: 'GAME',
                    icon: Icons.sports_esports,
                    color: AppColors.accent,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ChangeGameDialog(activeSession: active),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 5),

                // Pause / Resume
                Expanded(
                  child: _buildSmallAction(
                    label: isPaused ? 'RESUME' : 'PAUSE',
                    icon: isPaused ? Icons.play_arrow : Icons.pause,
                    color: isPaused ? AppColors.available : AppColors.paused,
                    onTap: () async {
                      final repo = ref.read(sessionRepositoryProvider);
                      if (isPaused) {
                        await repo.resumeSession(sessionId: session.id);
                      } else {
                        await repo.pauseSession(sessionId: session.id);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceBody(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.maintenance.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.build, size: 14, color: AppColors.maintenance),
          const SizedBox(height: 2),
          Text(
            room.description != null && room.description!.startsWith('Maintenance: ')
                ? room.description!
                : 'UNDER MAINTENANCE',
            style: GoogleFonts.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.maintenance,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: NeonButton(
              label: 'RESTORE AVAILABLE',
              icon: Icons.check_circle_outline,
              color: AppColors.primary,
              height: 28,
              fontSize: 10,
              onPressed: () async {
                await ref.read(roomRepositoryProvider).restoreRoomAvailability(room.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}
