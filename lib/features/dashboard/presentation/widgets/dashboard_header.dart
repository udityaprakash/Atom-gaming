import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../sessions/providers/session_provider.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsStreamProvider);

    return statsAsync.when(
      data: (stats) => Column(
        children: [
          // Row 1: Rooms status counters
          Row(
            children: [
              _buildStatChip(
                label: 'TOTAL',
                value: '${stats.totalRooms}',
                color: AppColors.primary,
                icon: Icons.meeting_room_outlined,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                label: 'AVAILABLE',
                value: '${stats.availableRooms}',
                color: AppColors.available,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                label: 'OCCUPIED',
                value: '${stats.occupiedRooms}',
                color: AppColors.occupied,
                icon: Icons.sports_esports,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                label: 'MAINT.',
                value: '${stats.maintenanceRooms}',
                color: AppColors.maintenance,
                icon: Icons.build_outlined,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: Today's Financial & Session summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricColumn(
                  title: "ACTIVE SESSIONS",
                  value: '${stats.activeSessions}',
                  color: AppColors.secondary,
                ),
                _buildDivider(),
                _buildMetricColumn(
                  title: "TODAY'S CASH",
                  value: CurrencyFormatter.format(stats.todayRevenue),
                  color: AppColors.available,
                ),
                _buildDivider(),
                _buildMetricColumn(
                  title: "UNPAID DUES",
                  value: CurrencyFormatter.format(stats.todayUnpaidDues),
                  color: stats.todayUnpaidDues > 0 ? AppColors.occupied : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ],
      ),
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.rajdhani(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.cardBorder,
    );
  }
}
