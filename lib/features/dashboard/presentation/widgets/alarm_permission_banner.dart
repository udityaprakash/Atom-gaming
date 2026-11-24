import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'alarm_permission_dialog.dart';

class AlarmPermissionBanner extends ConsumerStatefulWidget {
  const AlarmPermissionBanner({super.key});

  @override
  ConsumerState<AlarmPermissionBanner> createState() => _AlarmPermissionBannerState();
}

class _AlarmPermissionBannerState extends ConsumerState<AlarmPermissionBanner>
    with WidgetsBindingObserver {
  AlarmPermissionStatus? _status;
  bool _dismissedThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    final service = ref.read(permissionServiceProvider);
    final status = await service.checkAllPermissions();
    if (mounted) {
      setState(() => _status = status);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissedThisSession || _status == null || _status!.allCriticalGranted) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.occupied.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.occupied.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.occupied, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOCK SCREEN ALARM PERMISSIONS REQUIRED',
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.occupied,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Alarms may be delayed by Android Doze. Tap to enable exact alarms and battery exemption.',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.occupied,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () async {
              await AlarmPermissionDialog.show(context, isDismissible: true);
              _checkStatus();
            },
            child: Text(
              'FIX',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
            tooltip: 'Dismiss for now',
            onPressed: () => setState(() => _dismissedThisSession = true),
          ),
        ],
      ),
    );
  }
}
