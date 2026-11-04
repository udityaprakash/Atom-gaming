import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ABOUT ATOM',
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
          // Branding Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: const Icon(Icons.sports_esports, color: AppColors.primary, size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    'OFFLINE LOCAL-FIRST GAMING POS',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Overview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARCHITECTURE & PHILOSOPHY',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'atom is engineered specifically for PlayStation lounges, PC gaming cafes, and esports arenas. Built with an offline-first architecture, all gaming sessions, financial ledgers, customer records, and hardware statuses are stored locally on this device in SQLite.',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '• Zero Cloud Dependency: Operates completely offline during network blackouts.\n• Precise Billing Engine: Accurate second-level multi-segment calculation across transfers.\n• Exact Background Alarms: Android exact alarms wake the device for session expirations.\n• Complete Data Sovereignty: Instant JSON & CSV exports and SQLite snapshots.',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tech Stack Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TECHNOLOGY STACK',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTechRow('Flutter Framework', '3.x Material 3 Gaming UI'),
                _buildTechRow('Database ORM', 'Drift (SQLite Embedded)'),
                _buildTechRow('State Management', 'Riverpod 3.x'),
                _buildTechRow('Navigation', 'GoRouter Declarative Routing'),
                _buildTechRow('Visualizations', 'FL Chart Interactive Analytics'),
                _buildTechRow('Background Engine', 'Exact Alarms & Audio / Haptics'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Licenses Button
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            tileColor: AppColors.surface,
            leading: const Icon(Icons.description_outlined, color: AppColors.primary),
            title: Text(
              'Open Source Licenses',
              style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
            onTap: () => showLicensePage(
              context: context,
              applicationName: AppConstants.appName,
              applicationVersion: AppConstants.appVersion,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTechRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.rajdhani(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}
