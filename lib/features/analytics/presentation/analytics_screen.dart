import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/neon_button.dart';
import '../data/analytics_repository.dart';
import '../providers/analytics_provider.dart';
import 'widgets/daily_cash_closing_dialog.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(analyticsOverviewProvider);
    final roomMetricsAsync = ref.watch(roomMetricsProvider);
    final trendAsync = ref.watch(dailyRevenueTrendProvider);
    final equipmentShareAsync = ref.watch(equipmentRevenueShareProvider);
    final insightsAsync = ref.watch(businessInsightsProvider);
    final activePreset = ref.watch(analyticsTimePresetProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'REVENUE ANALYTICS',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.point_of_sale, color: AppColors.available),
            tooltip: 'Daily Cash Closing',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const DailyCashClosingDialog(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(analyticsOverviewProvider);
          ref.invalidate(roomMetricsProvider);
          ref.invalidate(dailyRevenueTrendProvider);
          ref.invalidate(equipmentRevenueShareProvider);
          ref.invalidate(businessInsightsProvider);
          ref.invalidate(dailyCashClosingProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Time Preset Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPresetChip(ref, 'Today', 'TODAY', activePreset),
                  const SizedBox(width: 6),
                  _buildPresetChip(ref, 'This Week', 'THIS_WEEK', activePreset),
                  const SizedBox(width: 6),
                  _buildPresetChip(ref, 'This Month', 'THIS_MONTH', activePreset),
                  const SizedBox(width: 6),
                  _buildPresetChip(ref, 'All Time', 'ALL', activePreset),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Financial Metrics Overview
            overviewAsync.when(
              data: (overview) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'CASH COLLECTED',
                          CurrencyFormatter.format(overview.actualCashCollected),
                          'Actual Physical Cash',
                          Icons.payments,
                          AppColors.available,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          'TOTAL BILLED',
                          CurrencyFormatter.format(overview.totalBilledRevenue),
                          '${overview.totalSessions} Sessions',
                          Icons.receipt_long,
                          AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'UNPAID DUES',
                          CurrencyFormatter.format(overview.outstandingUnpaid),
                          'Pending Debt',
                          Icons.money_off,
                          overview.outstandingUnpaid > 0 ? AppColors.occupied : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          'AVG SESSION',
                          TimeFormatter.formatDurationHuman(overview.averageSessionDuration),
                          'Avg ₹${overview.averageTicketSize.toInt()}',
                          Icons.timer,
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
            const SizedBox(height: 20),

            // Daily Cash Closing Quick Banner
            GlassCard(
              padding: const EdgeInsets.all(12),
              borderColor: AppColors.available.withValues(alpha: 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.available.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.point_of_sale, color: AppColors.available, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Cash Closing',
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Reconcile physical cash drawer balance',
                            style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  NeonButton(
                    label: 'CLOSE CASH',
                    icon: Icons.check,
                    color: AppColors.available,
                    height: 32,
                    fontSize: 11,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const DailyCashClosingDialog(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 7-Day Revenue Trend (FL Chart)
            Text(
              '7-DAY REVENUE & CASH TREND',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            trendAsync.when(
              data: (points) => _buildRevenueTrendChart(points),
              loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: 20),

            // Equipment Revenue Share (FL Chart)
            Text(
              'EQUIPMENT REVENUE SHARE',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            equipmentShareAsync.when(
              data: (shares) => _buildEquipmentShareChart(shares),
              loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: 20),

            // Business Insights
            Text(
              'BUSINESS INSIGHTS',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            insightsAsync.when(
              data: (insights) => _buildInsightsGrid(insights),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: 20),

            // Room Utilization Table
            Text(
              'ROOM UTILIZATION & OCCUPANCY',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            roomMetricsAsync.when(
              data: (metrics) => _buildRoomUtilizationList(metrics),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(WidgetRef ref, String label, String key, String activeKey) {
    final isSelected = key == activeKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(analyticsTimePresetProvider.notifier).setPreset(key);
      },
      labelStyle: GoogleFonts.rajdhani(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        color: isSelected ? Colors.white : AppColors.textMuted,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.rajdhani(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 0.6,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrendChart(List<DailyRevenueDataPoint> points) {
    if (points.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Center(
          child: Text('No revenue data recorded yet.', style: GoogleFonts.rajdhani(color: AppColors.textMuted)),
        ),
      );
    }

    final maxVal = points.fold<double>(100.0, (max, p) => p.billedAmount > max ? p.billedAmount : max);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegend(AppColors.available, 'Cash Collected'),
              const SizedBox(width: 12),
              _buildLegend(AppColors.secondary, 'Total Billed'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (val, meta) {
                        return Text(
                          val >= 1000 ? '₹${(val / 1000).toStringAsFixed(1)}k' : '₹${val.toInt()}',
                          style: GoogleFonts.rajdhani(fontSize: 9, color: AppColors.textMuted),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (idx, meta) {
                        final index = idx.toInt();
                        if (index < 0 || index >= points.length) return const SizedBox.shrink();
                        final d = points[index].date;
                        return Text(
                          '${d.day}/${d.month}',
                          style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.cardBorder, strokeWidth: 0.5),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(points.length, (idx) {
                  final p = points[idx];
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: p.cashCollected,
                        color: AppColors.available,
                        width: 7,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      BarChartRodData(
                        toY: p.billedAmount,
                        color: AppColors.secondary,
                        width: 7,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildEquipmentShareChart(List<EquipmentRevenueShare> shares) {
    if (shares.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Center(
          child: Text('No equipment data available.', style: GoogleFonts.rajdhani(color: AppColors.textMuted)),
        ),
      );
    }

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.available,
      AppColors.endingSoon,
      AppColors.paused,
      Colors.pinkAccent,
      Colors.tealAccent,
    ];

    final total = shares.fold<double>(0.0, (sum, s) => sum + s.totalRevenue);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 28,
                sections: List.generate(shares.length, (idx) {
                  final s = shares[idx];
                  return PieChartSectionData(
                    color: colors[idx % colors.length],
                    value: s.totalRevenue > 0 ? s.totalRevenue : 1,
                    radius: 26,
                    showTitle: false,
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(shares.length, (idx) {
                final s = shares[idx];
                final color = colors[idx % colors.length];
                final pct = total > 0 ? (s.totalRevenue / total * 100.0).toStringAsFixed(1) : '0';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(s.equipmentType, style: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textPrimary)),
                        ],
                      ),
                      Text(
                        '${CurrencyFormatter.format(s.totalRevenue)} ($pct%)',
                        style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsGrid(BusinessInsightsData insights) {
    final peakHourStr = insights.peakHour >= 12
        ? '${insights.peakHour == 12 ? 12 : insights.peakHour - 12}:00 PM'
        : '${insights.peakHour == 0 ? 12 : insights.peakHour}:00 AM';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                'PEAK GAMING HOUR',
                peakHourStr,
                'Highest Traffic',
                Icons.access_time_filled,
                AppColors.endingSoon,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInsightCard(
                'TOP EARNING ROOM',
                insights.highestRevenueRoom ?? 'N/A',
                'Highest Revenue',
                Icons.emoji_events,
                AppColors.available,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                'WEEKDAY REVENUE',
                CurrencyFormatter.format(insights.weekdayRevenue),
                'Mon - Fri Total',
                Icons.calendar_today,
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInsightCard(
                'WEEKEND REVENUE',
                CurrencyFormatter.format(insights.weekendRevenue),
                'Sat - Sun Total',
                Icons.weekend,
                AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
          Text(subtitle, style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildRoomUtilizationList(List<RoomAnalyticsMetric> metrics) {
    if (metrics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Center(
          child: Text('No room utilization data available.', style: GoogleFonts.rajdhani(color: AppColors.textMuted)),
        ),
      );
    }

    return Column(
      children: metrics.map((m) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${m.roomName} (${m.equipmentType})',
                    style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    CurrencyFormatter.format(m.totalBilledAmount),
                    style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.available),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sessions: ${m.sessionCount} • Time: ${TimeFormatter.formatDurationHuman(m.totalOccupiedDuration)}',
                    style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted),
                  ),
                  Text(
                    'Occupancy: ${m.occupancyPercentage}%',
                    style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
