import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/security_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../reservations/presentation/reservations_screen.dart';
import 'about_screen.dart';
import 'business_profile_screen.dart';
import 'data_management_screen.dart';
import 'notification_settings_screen.dart';
import 'widgets/manage_security_pin_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTINGS & SYSTEM',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Banner
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.sports_esports, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Version ${AppConstants.appVersion} • Offline Local-first POS',
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Business & Security Section
          Text(
            'BUSINESS & SECURITY',
            style: GoogleFonts.orbitron(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          _buildTile(
            context: context,
            title: 'Business Profile & Receipts',
            subtitle: 'Store name, address, contact phone, and operating hours',
            icon: Icons.storefront_outlined,
            trailingText: 'Configure',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusinessProfileScreen()),
              );
            },
          ),
          _buildTile(
            context: context,
            title: 'Security PIN Protection',
            subtitle: 'Guard database restores, data resets, and room deletions',
            icon: Icons.shield_outlined,
            trailingText: 'Manage',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const ManageSecurityPinDialog(),
              );
            },
          ),

          const SizedBox(height: 20),

          // Operations & Booking Section
          Text(
            'OPERATIONS & DATA',
            style: GoogleFonts.orbitron(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          _buildTile(
            context: context,
            title: 'Advance Console Reservations',
            subtitle: 'Slot booking with automated conflict checking',
            icon: Icons.event_available_outlined,
            trailingText: 'Manage',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReservationsScreen()),
              );
            },
          ),
          _buildTile(
            context: context,
            title: 'Database Backup & JSON/CSV Export',
            subtitle: 'Full offline data ownership, SQLite snapshots, and CSV files',
            icon: Icons.cloud_download_outlined,
            trailingText: 'Open',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DataManagementScreen()),
              );
            },
          ),
          _buildTile(
            context: context,
            title: 'Background Alarms & Notifications',
            subtitle: 'Configure sounds, vibration, and exact alarm schedules',
            icon: Icons.alarm,
            trailingText: 'Configure',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              );
            },
          ),

          const SizedBox(height: 20),

          // System Info Section
          Text(
            'SYSTEM ARCHITECTURE',
            style: GoogleFonts.orbitron(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          _buildTile(
            context: context,
            title: 'Cash-Only Ledger',
            subtitle: 'Digital & UPI payments reserved for future release (v1.2+)',
            icon: Icons.payments_outlined,
            trailingText: 'Active',
          ),
          _buildTile(
            context: context,
            title: 'SQLite Drift Database',
            subtitle: 'atom.sqlite local encrypted-ready persistent storage',
            icon: Icons.storage_outlined,
            trailingText: 'Ready',
          ),
          _buildTile(
            context: context,
            title: 'About atom & Licenses',
            subtitle: 'Architecture philosophy and open source credits',
            icon: Icons.info_outline,
            trailingText: 'View',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String trailingText,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trailingText,
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
