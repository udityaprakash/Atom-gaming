import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/security_service.dart';
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

  Future<void> _handleDeleteCustomer(BuildContext context, WidgetRef ref) async {
    final customer = customerWithStats.customer;
    final sessionCount = customerWithStats.totalVisits;
    final security = ref.read(securityServiceProvider);

    final String warningMsg = sessionCount > 0
        ? 'Customer "${customer.name}" has $sessionCount past gaming session(s). If deleted, all past sessions will remain in your database as Guest User sessions, preserving complete financial and playtime records.\n\nAre you sure you want to delete this customer?'
        : 'Are you sure you want to permanently delete customer "${customer.name}"?';

    final confirmed = await security.authenticateAction(
      context,
      title: 'Delete Customer?',
      message: warningMsg,
      confirmLabel: 'DELETE CUSTOMER',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(customerRepositoryProvider).deleteCustomer(customer.id);
      if (context.mounted) {
        Navigator.pop(context); // close profile sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sessionCount > 0
                  ? 'Customer deleted. Past sessions converted to Guest User.'
                  : 'Customer "${customer.name}" deleted.',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      }
    }
  }

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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    tooltip: 'Delete Customer',
                    onPressed: () => _handleDeleteCustomer(context, ref),
                  ),
                ],
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
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Lifetime Statistics Grid
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
                  'HOURS PLAYED',
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
                  'CASH SPENT',
                  CurrencyFormatter.format(customerWithStats.totalSpent),
                  Icons.payments,
                  AppColors.available,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'OUTSTANDING DEBT',
                  CurrencyFormatter.format(customerWithStats.outstandingDebt),
                  Icons.warning_amber,
                  customerWithStats.outstandingDebt > 0 ? AppColors.occupied : AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Gaming Sessions History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GAMING HISTORY',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${customerWithStats.totalVisits} sessions',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: sessionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text('Error loading history: $e', style: const TextStyle(color: AppColors.error)),
              ),
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No recorded sessions yet for this customer.',
                        style: GoogleFonts.rajdhani(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = sessions[index];
                    final session = item.session;
                    final isPaid = session.paymentStatus == AppConstants.paymentPaid;

                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isPaid ? AppColors.cardBorder : AppColors.occupied.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.sports_esports,
                              size: 18,
                              color: isPaid ? AppColors.primary : AppColors.occupied,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.roomName,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${TimeFormatter.formatDateTime(session.startedAt)} • ${TimeFormatter.formatDurationHuman(Duration(seconds: session.totalDurationSeconds))}',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.format(session.totalAmount),
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? AppColors.available.withValues(alpha: 0.15)
                                      : AppColors.occupied.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  session.paymentStatus,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isPaid ? AppColors.available : AppColors.occupied,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!isPaid) ...[
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.check_circle, size: 20, color: AppColors.available),
                              tooltip: 'Collect Cash',
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: AppColors.surface,
                                    title: const Text('Collect Cash Payment'),
                                    content: Text(
                                      'Collect ${CurrencyFormatter.format(session.totalAmount)} in CASH for this session?',
                                      style: GoogleFonts.rajdhani(),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.available),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('COLLECT CASH'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await ref.read(sessionRepositoryProvider).collectOutstandingCash(
                                    sessionId: session.id,
                                    amountCollected: session.totalAmount,
                                  );
                                  ref.invalidate(customerSessionsFamilyProvider(customer.id));
                                  ref.invalidate(customersWithStatsStreamProvider);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
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
