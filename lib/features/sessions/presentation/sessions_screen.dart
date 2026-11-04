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
import '../../billing/presentation/widgets/receipt_dialog.dart';
import '../../rooms/providers/room_provider.dart';
import '../data/session_repository.dart';
import '../providers/session_provider.dart';
import 'widgets/end_session_dialog.dart';
import 'widgets/extend_session_sheet.dart';
import 'widgets/session_timeline_dialog.dart';
import 'widgets/transfer_room_dialog.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionsAsync = ref.watch(activeRoomSessionsStreamProvider);
    final unpaidSessionsAsync = ref.watch(unpaidSessionsStreamProvider);

    final activeCount = activeSessionsAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    final unpaidCount = unpaidSessionsAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'SESSIONS & BILLING',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, size: 14),
                    const SizedBox(width: 4),
                    Text('ACTIVE ($activeCount)'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.money_off,
                      size: 14,
                      color: unpaidCount > 0 ? AppColors.occupied : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'UNPAID ($unpaidCount)',
                      style: TextStyle(
                        color: unpaidCount > 0 ? AppColors.occupied : null,
                      ),
                    ),
                  ],
                ),
              ),
              const Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 14),
                    SizedBox(width: 4),
                    Text('HISTORY'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Active Sessions
            _buildActiveSessionsTab(context, ref, activeSessionsAsync),

            // Tab 2: Unpaid Sessions
            _buildUnpaidSessionsTab(context, ref, unpaidSessionsAsync),

            // Tab 3: Session History
            _buildHistoryTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ActiveRoomSession>> activeSessionsAsync,
  ) {
    return activeSessionsAsync.when(
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
            return _buildActiveSessionCard(context, ref, active);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildUnpaidSessionsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<UnpaidSessionItem>> unpaidSessionsAsync,
  ) {
    return unpaidSessionsAsync.when(
      data: (unpaidSessions) {
        if (unpaidSessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 48, color: AppColors.available),
                const SizedBox(height: 12),
                Text(
                  'Zero Outstanding Dues',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'All completed sessions are settled in cash.',
                  style: GoogleFonts.rajdhani(color: AppColors.textMuted),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: unpaidSessions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = unpaidSessions[index];
            return _buildUnpaidSessionCard(context, ref, item);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildHistoryTab(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(sessionHistoryStreamProvider);
    final datePreset = ref.watch(sessionHistoryDatePresetProvider);
    final paymentStatus = ref.watch(sessionHistoryPaymentStatusProvider);
    final selectedRoomId = ref.watch(sessionHistoryRoomIdProvider);
    final allRoomsAsync = ref.watch(allRoomsStreamProvider);

    return Column(
      children: [
        // Filter Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: AppColors.surface,
          child: Column(
            children: [
              // Search Input
              TextField(
                onChanged: (val) {
                  ref.read(sessionHistorySearchQueryProvider.notifier).setQuery(val);
                },
                style: GoogleFonts.rajdhani(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search customer name or session ID...',
                  hintStyle: GoogleFonts.rajdhani(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Date Preset Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All Time',
                      isSelected: datePreset == 'ALL',
                      onSelected: () => ref.read(sessionHistoryDatePresetProvider.notifier).setPreset('ALL'),
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'Today',
                      isSelected: datePreset == 'TODAY',
                      onSelected: () => ref.read(sessionHistoryDatePresetProvider.notifier).setPreset('TODAY'),
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'Yesterday',
                      isSelected: datePreset == 'YESTERDAY',
                      onSelected: () => ref.read(sessionHistoryDatePresetProvider.notifier).setPreset('YESTERDAY'),
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'This Week',
                      isSelected: datePreset == 'THIS_WEEK',
                      onSelected: () => ref.read(sessionHistoryDatePresetProvider.notifier).setPreset('THIS_WEEK'),
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'This Month',
                      isSelected: datePreset == 'THIS_MONTH',
                      onSelected: () => ref.read(sessionHistoryDatePresetProvider.notifier).setPreset('THIS_MONTH'),
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'Custom Range',
                      isSelected: datePreset == 'CUSTOM',
                      onSelected: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2025),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (picked != null) {
                          ref.read(sessionHistoryCustomRangeProvider.notifier).setRange(picked);
                          ref.read(sessionHistoryDatePresetProvider.notifier).setPreset('CUSTOM');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Secondary Filters: Payment Status & Room selector
              Row(
                children: [
                  // Payment Status Chip
                  _buildMiniChip(
                    label: 'Status: $paymentStatus',
                    onTap: () {
                      final next = paymentStatus == 'ALL'
                          ? 'PAID'
                          : paymentStatus == 'PAID'
                              ? 'UNPAID'
                              : 'ALL';
                      ref.read(sessionHistoryPaymentStatusProvider.notifier).setStatus(next);
                    },
                  ),
                  const SizedBox(width: 8),

                  // Room Selector
                  Expanded(
                    child: allRoomsAsync.maybeWhen(
                      data: (rooms) => DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedRoomId,
                          isDense: true,
                          isExpanded: true,
                          dropdownColor: AppColors.surfaceElevated,
                          hint: Text('All Rooms', style: GoogleFonts.rajdhani(color: AppColors.textMuted)),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Rooms', style: GoogleFonts.rajdhani(color: AppColors.textPrimary)),
                            ),
                            ...rooms.map(
                              (r) => DropdownMenuItem<String?>(
                                value: r.id,
                                child: Text(r.roomName, style: GoogleFonts.rajdhani(color: AppColors.textPrimary)),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            ref.read(sessionHistoryRoomIdProvider.notifier).setRoomId(val);
                          },
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // History Content
        Expanded(
          child: historyAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_toggle_off, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'No Historical Sessions',
                        style: GoogleFonts.orbitron(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Completed sessions will automatically appear here.',
                        style: GoogleFonts.rajdhani(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _buildHistoryCard(context, ref, item);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: GoogleFonts.rajdhani(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        color: isSelected ? Colors.white : AppColors.textMuted,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
      ),
    );
  }

  Widget _buildMiniChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WidgetRef ref, HistoricalSessionItem item) {
    final s = item.session;
    final isPaid = s.paymentStatus == AppConstants.paymentPaid;
    final shortId = s.id.length > 8 ? s.id.substring(0, 8).toUpperCase() : s.id.toUpperCase();

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => SessionTimelineDialog(sessionId: s.id),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderColor: isPaid ? AppColors.cardBorder : AppColors.occupied.withValues(alpha: 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: ID, Date, Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '#$shortId',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      TimeFormatter.formatDate(s.startedAt),
                      style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                StatusBadge(status: s.paymentStatus),
              ],
            ),
            const SizedBox(height: 6),

            // Room and Customer Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.roomDisplay,
                      style: GoogleFonts.orbitron(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Customer: ${item.customer?.name ?? "Walk-in Guest"}',
                      style: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(s.totalAmount),
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPaid ? AppColors.available : AppColors.occupied,
                      ),
                    ),
                    Text(
                      TimeFormatter.formatDurationHuman(Duration(seconds: s.totalDurationSeconds)),
                      style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),

            if (item.extensionCount > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.more_time, size: 12, color: AppColors.endingSoon),
                  const SizedBox(width: 4),
                  Text(
                    '${item.extensionCount} extension(s) logged',
                    style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.endingSoon),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 6),

            // Actions row: Timeline & Receipt
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.history_edu, size: 14, color: AppColors.textSecondary),
                  label: Text('TIMELINE', style: GoogleFonts.rajdhani(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => SessionTimelineDialog(sessionId: s.id),
                    );
                  },
                ),
                const SizedBox(width: 6),
                TextButton.icon(
                  icon: const Icon(Icons.receipt_long, size: 14, color: AppColors.primary),
                  label: Text('RECEIPT', style: GoogleFonts.rajdhani(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () async {
                    final repo = ref.read(sessionRepositoryProvider);
                    final receipt = await repo.getSessionReceiptData(s.id);
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => ReceiptDialog(receiptData: receipt),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionCard(BuildContext context, WidgetRef ref, ActiveRoomSession active) {
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
              : AppColors.cardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Room Name & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                active.room.roomName,
                style: GoogleFonts.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              StatusBadge(
                status: isPaused
                    ? AppConstants.sessionPaused
                    : isOvertime
                        ? AppConstants.sessionOvertime
                        : AppConstants.sessionActive,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Customer details
          if (active.customer != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${active.customer!.name} (${active.customer!.phone ?? "No phone"})',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 10),

          // Timers & Estimated Bill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('ELAPSED', TimeFormatter.formatDurationHuman(elapsed)),
              _buildMetric(
                isOvertime ? 'OVERTIME' : 'REMAINING',
                isOvertime
                    ? '+${TimeFormatter.formatDurationHuman(remaining.abs())}'
                    : TimeFormatter.formatDurationHuman(remaining),
                isHighlighted: isOvertime,
              ),
              _buildMetric('EST. BILL', CurrencyFormatter.format(estimatedCharge), isHighlighted: true),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons: 2 rows of 2 buttons for generous touch targets & zero overflow
          Row(
            children: [
              // Extend Button
              Expanded(
                child: NeonButton(
                  label: '+ EXTEND',
                  icon: Icons.add_alarm,
                  color: AppColors.endingSoon,
                  isOutlined: true,
                  height: 36,
                  fontSize: 12,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => ExtendSessionSheet(activeSession: active),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Transfer Button
              Expanded(
                child: NeonButton(
                  label: 'TRANSFER',
                  icon: Icons.swap_horiz,
                  color: AppColors.primary,
                  isOutlined: true,
                  height: 36,
                  fontSize: 12,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => TransferRoomDialog(activeSession: active),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              // Pause / Resume Button
              Expanded(
                child: NeonButton(
                  label: isPaused ? 'RESUME' : 'PAUSE',
                  icon: isPaused ? Icons.play_arrow : Icons.pause,
                  color: AppColors.paused,
                  isOutlined: true,
                  height: 36,
                  fontSize: 12,
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
              const SizedBox(width: 8),

              // End & Bill Button
              Expanded(
                child: NeonButton(
                  label: 'END & BILL',
                  icon: Icons.stop_circle_outlined,
                  color: AppColors.occupied,
                  height: 36,
                  fontSize: 12,
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => EndSessionDialog(activeSession: active),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnpaidSessionCard(BuildContext context, WidgetRef ref, UnpaidSessionItem item) {
    final shortId = item.session.id.length > 8
        ? item.session.id.substring(0, 8).toUpperCase()
        : item.session.id.toUpperCase();

    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.occupied.withValues(alpha: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.occupied),
                  const SizedBox(width: 6),
                  Text(
                    'SESSION #$shortId',
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.occupied.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.occupied),
                ),
                child: Text(
                  'UNPAID DUE',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.occupied,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.customer?.name ?? 'Walk-in Guest',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${item.room.roomName} (${item.room.equipmentType})',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    'Ended: ${TimeFormatter.formatTime(item.endedAt)}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'OUTSTANDING',
                    style: GoogleFonts.rajdhani(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.amountDue),
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.occupied,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 10),

          // Actions
          Row(
            children: [
              // Receipt Button
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.receipt_long, size: 15, color: AppColors.textSecondary),
                  label: Text(
                    'RECEIPT',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () async {
                    final repo = ref.read(sessionRepositoryProvider);
                    final receipt = await repo.getSessionReceiptData(item.session.id);
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => ReceiptDialog(receiptData: receipt),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Collect Cash Button
              Expanded(
                flex: 2,
                child: NeonButton(
                  label: 'COLLECT CASH',
                  icon: Icons.payments,
                  color: AppColors.available,
                  height: 38,
                  fontSize: 12,
                  onPressed: () => _showCollectCashDialog(context, ref, item),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCollectCashDialog(BuildContext context, WidgetRef ref, UnpaidSessionItem item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.payments, color: AppColors.available, size: 22),
            const SizedBox(width: 8),
            Text(
              'COLLECT CASH PAYMENT',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receive ${CurrencyFormatter.format(item.amountDue)} in CASH from ${item.customer?.name ?? "Customer"}?',
              style: GoogleFonts.rajdhani(fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'This will mark the debt as settled and record the actual collection timestamp.',
              style: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('CANCEL', style: GoogleFonts.rajdhani(color: AppColors.textMuted)),
          ),
          NeonButton(
            label: 'CONFIRM CASH RECEIVED',
            icon: Icons.check,
            color: AppColors.available,
            height: 38,
            fontSize: 12,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                final repo = ref.read(sessionRepositoryProvider);
                await repo.collectOutstandingCash(sessionId: item.session.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cash payment of ${CurrencyFormatter.format(item.amountDue)} recorded successfully!',
                      ),
                      backgroundColor: AppColors.surfaceElevated,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
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
