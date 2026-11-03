import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../sessions/providers/session_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsStreamProvider);

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
      ),
      body: statsAsync.when(
        data: (stats) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TODAY'S FINANCIAL OVERVIEW",
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      'Cash Collected (Today)',
                      CurrencyFormatter.format(stats.todayRevenue),
                      AppColors.available,
                    ),
                    const Divider(color: AppColors.cardBorder, height: 20),
                    _buildRow(
                      'Outstanding Unpaid Dues',
                      CurrencyFormatter.format(stats.todayUnpaidDues),
                      stats.todayUnpaidDues > 0 ? AppColors.occupied : AppColors.textMuted,
                    ),
                    const Divider(color: AppColors.cardBorder, height: 20),
                    _buildRow(
                      'Completed Sessions',
                      '${stats.todayCompletedSessions}',
                      AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGlow),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insights, color: AppColors.secondary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Analytics Suite',
                            style: GoogleFonts.orbitron(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Interactive FL Chart trends, room utilization graphs and cash drawer reconciliation will unlock in Phase 4.',
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
