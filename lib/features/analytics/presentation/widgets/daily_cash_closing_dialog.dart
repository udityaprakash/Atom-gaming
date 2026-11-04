import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../providers/analytics_provider.dart';

class DailyCashClosingDialog extends ConsumerStatefulWidget {
  const DailyCashClosingDialog({super.key});

  @override
  ConsumerState<DailyCashClosingDialog> createState() => _DailyCashClosingDialogState();
}

class _DailyCashClosingDialogState extends ConsumerState<DailyCashClosingDialog> {
  final _cashCountedController = TextEditingController();
  double? _physicalCashCounted;

  @override
  void dispose() {
    _cashCountedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final closingAsync = ref.watch(dailyCashClosingProvider);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.point_of_sale, color: AppColors.available, size: 24),
              const SizedBox(width: 8),
              Text(
                'DAILY CASH CLOSING',
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
        child: closingAsync.when(
          data: (report) {
            final difference = _physicalCashCounted != null
                ? (_physicalCashCounted! - report.totalCashInDrawer)
                : null;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Reconciliation for ${TimeFormatter.formatDate(report.date)}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cash Drawer Balance Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.available.withValues(alpha: 0.1),
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
                              'TOTAL CASH IN DRAWER',
                              style: GoogleFonts.rajdhani(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'Physical Cash Expected',
                              style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.format(report.totalCashInDrawer),
                          style: GoogleFonts.orbitron(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.available,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Cash Inflow Breakdown
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        _buildRow(
                          "Today's Sessions Cash",
                          CurrencyFormatter.format(report.cashFromTodaySessions),
                          AppColors.textPrimary,
                        ),
                        const SizedBox(height: 6),
                        _buildRow(
                          "Past Unpaid Debt Settled Today",
                          CurrencyFormatter.format(report.cashFromPastUnpaidSessions),
                          AppColors.primary,
                        ),
                        const Divider(color: AppColors.cardBorder, height: 16),
                        _buildRow(
                          "Today's Unpaid Dues Accrued",
                          CurrencyFormatter.format(report.todayUnpaidDebtAccrued),
                          report.todayUnpaidDebtAccrued > 0 ? AppColors.occupied : AppColors.textMuted,
                        ),
                        const SizedBox(height: 6),
                        _buildRow(
                          "Today's Total Billed Revenue",
                          CurrencyFormatter.format(report.totalBilledToday),
                          AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Physical Count Input & Reconciliation
                  Text(
                    'CASH DRAWER RECONCILIATION',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _cashCountedController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) {
                      setState(() {
                        _physicalCashCounted = double.tryParse(val.trim());
                      });
                    },
                    style: GoogleFonts.orbitron(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Actual Physical Cash Counted (₹)',
                      labelStyle: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.money, size: 20, color: AppColors.available),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  if (difference != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: difference == 0
                            ? AppColors.available.withValues(alpha: 0.15)
                            : (difference > 0 ? AppColors.endingSoon : AppColors.occupied)
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            difference == 0
                                ? 'PERFECT MATCH'
                                : (difference > 0 ? 'CASH SURPLUS' : 'CASH SHORTAGE'),
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: difference == 0
                                  ? AppColors.available
                                  : (difference > 0 ? AppColors.endingSoon : AppColors.occupied),
                            ),
                          ),
                          Text(
                            difference == 0
                                ? '₹0 Difference'
                                : '${difference > 0 ? "+" : ""}${CurrencyFormatter.format(difference)}',
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: difference == 0
                                  ? AppColors.available
                                  : (difference > 0 ? AppColors.endingSoon : AppColors.occupied),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
        NeonButton(
          label: 'DONE',
          icon: Icons.check,
          color: AppColors.available,
          height: 38,
          fontSize: 12,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textMuted)),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
