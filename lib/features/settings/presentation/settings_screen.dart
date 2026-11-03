import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTINGS & ABOUT',
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
          Container(
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
                Column(
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
                      'Version ${AppConstants.appVersion} • Offline Local-first',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'SYSTEM & MODULES',
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          _buildTile(
            context: context,
            title: 'Cash-Only Ledger',
            subtitle: 'Digital & UPI payments reserved for future release',
            icon: Icons.payments_outlined,
            trailingText: 'Active',
          ),
          _buildTile(
            context: context,
            title: 'SQLite Drift Database',
            subtitle: 'Local-first persistent offline storage',
            icon: Icons.storage_outlined,
            trailingText: 'Ready',
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
          _buildTile(
            context: context,
            title: 'Database Backup & JSON/CSV Export',
            subtitle: 'Full offline data ownership & snapshots',
            icon: Icons.cloud_download_outlined,
            trailingText: 'Phase 5',
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
