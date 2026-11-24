import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/neon_button.dart';

class AlarmPermissionDialog extends ConsumerStatefulWidget {
  final bool isDismissible;

  const AlarmPermissionDialog({
    super.key,
    this.isDismissible = true,
  });

  static Future<void> show(BuildContext context, {bool isDismissible = true}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (_) => AlarmPermissionDialog(isDismissible: isDismissible),
    );
  }

  @override
  ConsumerState<AlarmPermissionDialog> createState() => _AlarmPermissionDialogState();
}

class _AlarmPermissionDialogState extends ConsumerState<AlarmPermissionDialog>
    with WidgetsBindingObserver {
  AlarmPermissionStatus? _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatus();
    }
  }

  Future<void> _refreshStatus() async {
    final service = ref.read(permissionServiceProvider);
    final status = await service.checkAllPermissions();
    if (mounted) {
      setState(() {
        _status = status;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(permissionServiceProvider);
    final isAllGranted = _status?.allCriticalGranted ?? false;

    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isAllGranted ? AppColors.available : AppColors.primary,
          width: 1.5,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isAllGranted ? AppColors.available : AppColors.primary)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isAllGranted ? AppColors.available : AppColors.primary,
                      ),
                    ),
                    child: Icon(
                      isAllGranted ? Icons.verified_user : Icons.alarm_on,
                      color: isAllGranted ? AppColors.available : AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAllGranted
                              ? 'ALARMS FULLY CONFIGURED'
                              : 'LOCK SCREEN ALARM SETUP',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isAllGranted
                              ? 'Session alarms will ring accurately on lock screen'
                              : 'Required so session alarms wake your device on time',
                          style: GoogleFonts.rajdhani(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else ...[
                // Item 1: Exact Alarms
                _buildPermissionRow(
                  title: '1. Exact Alarms & Reminders',
                  description:
                      'Permits ATOM to sound buzzers at the exact second a session finishes.',
                  isGranted: _status?.exactAlarmsGranted ?? false,
                  icon: Icons.alarm,
                  onAction: () async {
                    await service.requestExactAlarms();
                  },
                ),
                const SizedBox(height: 12),

                // Item 2: Battery Optimization Exemption
                _buildPermissionRow(
                  title: '2. Unrestricted Battery / Doze Exemption',
                  description:
                      'Prevents Android from freezing timers and deferring alarms while the phone is locked.',
                  isGranted: _status?.batteryOptimizationIgnored ?? false,
                  icon: Icons.battery_charging_full,
                  onAction: () async {
                    await service.requestIgnoreBatteryOptimization();
                  },
                ),
                const SizedBox(height: 12),

                // Item 3: Notifications
                _buildPermissionRow(
                  title: '3. Full-Screen Notifications',
                  description:
                      'Allows high-priority alert cards to pop up over the keyguard.',
                  isGranted: _status?.notificationsGranted ?? false,
                  icon: Icons.notifications_active,
                  onAction: () async {
                    await service.requestNotifications();
                  },
                ),
              ],

              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  if (widget.isDismissible && !isAllGranted)
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          await service.setCompletedOnboarding(true);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        child: Text(
                          'LATER',
                          style: GoogleFonts.rajdhani(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: NeonButton(
                      label: isAllGranted ? 'DONE' : 'CHECK & FINISH',
                      icon: isAllGranted ? Icons.check_circle : Icons.refresh,
                      color: isAllGranted ? AppColors.available : AppColors.primary,
                      height: 44,
                      onPressed: () async {
                        await _refreshStatus();
                        if (_status?.allCriticalGranted ?? false) {
                          await service.setCompletedOnboarding(true);
                          if (context.mounted) Navigator.of(context).pop();
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enable the remaining permissions to ensure alarms trigger on lock screen.',
                                  style: GoogleFonts.rajdhani(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.occupied,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRow({
    required String title,
    required String description,
    required bool isGranted,
    required IconData icon,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isGranted
              ? AppColors.available.withValues(alpha: 0.4)
              : AppColors.occupied.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isGranted ? AppColors.available : AppColors.occupied)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isGranted ? AppColors.available : AppColors.occupied,
            ),
          ),
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
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isGranted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.available.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.available.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 14, color: AppColors.available),
                  const SizedBox(width: 4),
                  Text(
                    'ACTIVE',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.available,
                    ),
                  ),
                ],
              ),
            )
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: onAction,
              child: Text(
                'ENABLE',
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
