import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/data_export_service.dart';
import '../../../core/services/security_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neon_button.dart';

class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  List<BackupMetadata> _backups = [];
  bool _isLoadingBackups = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoadingBackups = true);
    try {
      final list = await BackupService.getBackupsList();
      if (mounted) {
        setState(() {
          _backups = list;
          _isLoadingBackups = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingBackups = false);
    }
  }

  Future<void> _exportJson() async {
    setState(() => _isProcessing = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final json = await DataExportService.exportAllToJson(db);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      await DataExportService.saveAndShare(
        content: json,
        fileName: 'atom_export_$timestamp.json',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _exportSessionsCsv() async {
    setState(() => _isProcessing = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final csv = await DataExportService.exportSessionsToCsv(db);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      await DataExportService.saveAndShare(
        content: csv,
        fileName: 'atom_sessions_$timestamp.csv',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _exportPaymentsCsv() async {
    setState(() => _isProcessing = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final csv = await DataExportService.exportPaymentsToCsv(db);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      await DataExportService.saveAndShare(
        content: csv,
        fileName: 'atom_payments_$timestamp.csv',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _exportCustomersCsv() async {
    setState(() => _isProcessing = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final csv = await DataExportService.exportCustomersToCsv(db);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      await DataExportService.saveAndShare(
        content: csv,
        fileName: 'atom_customers_$timestamp.csv',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isProcessing = true);
    try {
      final meta = await BackupService.createBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created: ${meta.fileName} (${meta.formattedSize})'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      await _loadBackups();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _restoreBackup(BackupMetadata backup) async {
    final security = ref.read(securityServiceProvider);
    final confirmed = await security.authenticateAction(
      context,
      title: 'Restore Database?',
      message: 'Restoring snapshot "${backup.fileName}" will replace all current database state with data from ${DateFormat('MMM d, yyyy hh:mm a').format(backup.createdAt)}. Are you sure you want to proceed?',
      confirmLabel: 'CONFIRM RESTORE',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await BackupService.restoreBackup(File(backup.filePath));
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Database Restored',
              style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success),
            ),
            content: Text(
              'The database has been restored successfully. Please restart or refresh the application to view the restored records.',
              style: GoogleFonts.rajdhani(color: AppColors.textSecondary),
            ),
            actions: [
              NeonButton(
                label: 'OK',
                color: AppColors.primary,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _deleteBackup(BackupMetadata backup) async {
    final security = ref.read(securityServiceProvider);
    final confirmed = await security.authenticateAction(
      context,
      title: 'Delete Backup Snapshot?',
      message: 'Permanently remove "${backup.fileName}" from device storage?',
      confirmLabel: 'DELETE',
      isDestructive: true,
    );

    if (confirmed == true) {
      await BackupService.deleteBackup(File(backup.filePath));
      await _loadBackups();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DATA & BACKUP',
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
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.cloud_sync, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Offline Local Ownership',
                        style: GoogleFonts.orbitron(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Export standard JSON/CSV files or capture standalone SQLite snapshots at any time.',
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 1: Exports
          Text(
            'DATA EXPORT (JSON & CSV)',
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          _buildActionTile(
            title: 'Export Full Database (JSON)',
            subtitle: 'Complete database tables in standard JSON format',
            icon: Icons.data_object,
            actionLabel: 'EXPORT JSON',
            onTap: _isProcessing ? null : _exportJson,
          ),
          _buildActionTile(
            title: 'Export Sessions (CSV)',
            subtitle: 'Complete gaming session logs and duration records',
            icon: Icons.table_chart_outlined,
            actionLabel: 'EXPORT CSV',
            onTap: _isProcessing ? null : _exportSessionsCsv,
          ),
          _buildActionTile(
            title: 'Export Cash Payments (CSV)',
            subtitle: 'All cash receipts, timestamps, and payment statuses',
            icon: Icons.receipt_long,
            actionLabel: 'EXPORT CSV',
            onTap: _isProcessing ? null : _exportPaymentsCsv,
          ),
          _buildActionTile(
            title: 'Export Customer Directory (CSV)',
            subtitle: 'Customer list with contact information and visit metrics',
            icon: Icons.contacts_outlined,
            actionLabel: 'EXPORT CSV',
            onTap: _isProcessing ? null : _exportCustomersCsv,
          ),

          const SizedBox(height: 24),

          // Section 2: Snapshots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SQLITE DATABASE SNAPSHOTS',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              NeonButton(
                label: '+ CREATE SNAPSHOT',
                color: AppColors.primary,
                height: 32,
                fontSize: 11,
                onPressed: _isProcessing ? null : _createBackup,
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoadingBackups)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ))
          else if (_backups.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                'No database snapshots created yet. Tap "+ CREATE SNAPSHOT" to generate an offline copy.',
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ..._backups.map((b) => _buildBackupItem(b, dateFormat)),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String actionLabel,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NeonButton(
            label: actionLabel,
            color: AppColors.primary,
            height: 30,
            fontSize: 10,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildBackupItem(BackupMetadata backup, DateFormat dateFormat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            children: [
              const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  backup.fileName,
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  backup.formattedSize,
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dateFormat.format(backup.createdAt),
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.share, size: 18, color: AppColors.textSecondary),
                tooltip: 'Share Snapshot',
                onPressed: () => BackupService.shareBackup(backup),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                tooltip: 'Delete Snapshot',
                onPressed: () => _deleteBackup(backup),
              ),
              const SizedBox(width: 8),
              NeonButton(
                label: 'RESTORE',
                icon: Icons.restore,
                color: AppColors.warning,
                height: 30,
                fontSize: 10,
                onPressed: () => _restoreBackup(backup),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
