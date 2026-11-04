import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/security_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/customer_repository.dart';
import '../providers/customer_provider.dart';
import 'widgets/add_edit_customer_dialog.dart';
import 'widgets/customer_profile_sheet.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersWithStatsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CUSTOMER DIRECTORY',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: AppColors.primary),
            tooltip: 'Add Customer',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddEditCustomerDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(customerSearchQueryProvider.notifier).setQuery(val);
              },
              style: GoogleFonts.rajdhani(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search customer by name or phone...',
                hintStyle: GoogleFonts.rajdhani(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(customerSearchQueryProvider.notifier).setQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
          ),

          // Customers List
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                if (customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No Customers Found',
                          style: GoogleFonts.orbitron(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No match for "${_searchController.text}".'
                              : 'Register regular gamers to track visits and gaming history.',
                          style: GoogleFonts.rajdhani(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: customers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = customers[index];
                    return _buildCustomerCard(context, item);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerWithStats item) {
    final customer = item.customer;
    final hasDebt = item.outstandingDebt > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => CustomerProfileSheet(customerWithStats: item),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderColor: hasDebt ? AppColors.occupied.withValues(alpha: 0.6) : AppColors.cardBorder,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                        style: GoogleFonts.orbitron(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (customer.phone != null && customer.phone!.isNotEmpty)
                          Text(
                            customer.phone!,
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasDebt)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.occupied.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.occupied),
                        ),
                        child: Text(
                          'DUE: ${CurrencyFormatter.format(item.outstandingDebt)}',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.occupied,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      tooltip: 'Delete Customer',
                      onPressed: () => _confirmDeleteCustomer(context, ref, item),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 8),

            // Statistics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatPill('Visits', '${item.totalVisits}', Icons.sports_esports),
                _buildStatPill('Hours', TimeFormatter.formatDurationHuman(item.totalDuration), Icons.timer),
                _buildStatPill('Spent', CurrencyFormatter.format(item.totalSpent), Icons.payments),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteCustomer(BuildContext context, WidgetRef ref, CustomerWithStats item) async {
    final customer = item.customer;
    final sessionCount = item.totalVisits;
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
}
