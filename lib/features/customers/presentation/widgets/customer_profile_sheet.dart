import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../billing/presentation/widgets/receipt_dialog.dart';
import '../../../sessions/providers/session_provider.dart';
import '../../data/customer_repository.dart';
import '../../providers/customer_provider.dart';
import 'add_edit_customer_dialog.dart';

class CustomerProfileSheet extends ConsumerWidget {
  final CustomerWithStats customerWithStats;

  const CustomerProfileSheet({super.key, required this.customerWithStats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = customerWithStats.customer;
    final sessionsAsync = ref.watch(customerSessionsFamilyProvider(customer.id));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone?.isNotEmpty == true ? customer.phone! : 'No phone registered',
                          style: GoogleFonts.rajdhani(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                tooltip: 'Edit Customer',
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => AddEditCustomerDialog(customer: customer),
                  );
                },
              ),
            ],
          ),

          if (customer.notes != null && customer.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      customer.notes!,
                      style: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Metrics Grid (4 items)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'TOTAL VISITS',
                  '${customerWithStats.totalVisits}',
                  Icons.sports_esports,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'PLAYED TIME',
                  TimeFormatter.formatDurationHuman(customerWithStats.totalDuration),
                  Icons.timer,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'TOTAL PAID',
                  CurrencyFormatter.format(customerWithStats.totalSpent),
                  Icons.payments,
                  AppColors.available,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'OUTSTANDING',
                  CurrencyFormatter.format(customerWithStats.outstandingDebt),
                  Icons.warning_amber_rounded,
                  customerWithStats.outstandingDebt > 0 ? AppColors.occupied : AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            'PAST GAMING SESSIONS',
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          // Sessions List
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'No previous sessions recorded.',
                        style: GoogleFonts.rajdhani(color: AppColors.textMuted),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = sessions[index];
                    final s = item.session;
                    final isPaid = s.paymentStatus == AppConstants.paymentPaid;

                    return GlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.roomName,
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${TimeFormatter.formatDate(s.startedAt)} • ${TimeFormatter.formatDurationHuman(Duration(seconds: s.totalDurationSeconds))}',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(s.totalAmount),
                                    style: GoogleFonts.orbitron(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isPaid ? AppColors.available : AppColors.occupied,
                                    ),
                                  ),
                                  Text(
                                    s.paymentStatus,
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isPaid ? AppColors.available : AppColors.occupied,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.receipt_long, size: 18, color: AppColors.primary),
                                tooltip: 'View Receipt',
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
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.rajdhani(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
