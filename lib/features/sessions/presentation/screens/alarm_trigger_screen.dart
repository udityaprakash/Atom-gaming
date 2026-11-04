import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/alarm_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../data/session_repository.dart';
import '../../providers/session_provider.dart';
import '../widgets/end_session_dialog.dart';
import '../widgets/extend_session_sheet.dart';

class AlarmTriggerScreen extends ConsumerStatefulWidget {
  final ActiveRoomSession activeSession;

  const AlarmTriggerScreen({super.key, required this.activeSession});

  @override
  ConsumerState<AlarmTriggerScreen> createState() => _AlarmTriggerScreenState();
}

class _AlarmTriggerScreenState extends ConsumerState<AlarmTriggerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Start audio & haptic buzzer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alarmServiceProvider).startContinuousBuzzer();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    // Stop buzzing whenever this screen is exited
    ref.read(alarmServiceProvider).stopContinuousBuzzer();
    super.dispose();
  }

  void _stopAndDismiss() {
    ref.read(alarmServiceProvider).stopContinuousBuzzer();
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _handleFreeStyle() async {
    ref.read(alarmServiceProvider).stopContinuousBuzzer();
    final repo = ref.read(sessionRepositoryProvider);
    // If the session was auto-paused on expiry, resume it so overtime timer runs freely
    await repo.resumeSession(sessionId: widget.activeSession.session.id);

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Free Style active: Overtime billing started for ${widget.activeSession.room.roomName}!',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: AppColors.available,
        ),
      );
    }
  }

  void _handleExtend() {
    ref.read(alarmServiceProvider).stopContinuousBuzzer();
    Navigator.of(context, rootNavigator: true).pop();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExtendSessionSheet(activeSession: widget.activeSession),
    );
  }

  void _handleEndSession() {
    ref.read(alarmServiceProvider).stopContinuousBuzzer();
    Navigator.of(context, rootNavigator: true).pop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EndSessionDialog(activeSession: widget.activeSession),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.activeSession.room;
    final customer = widget.activeSession.customer;
    final isPaused = widget.activeSession.session.status == AppConstants.sessionPaused;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(alarmServiceProvider).stopContinuousBuzzer();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0609),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.occupied.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.occupied.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.alarm_on, color: AppColors.occupied, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'SESSION EXPIRED ALERT',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.occupied,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pulsing Center Alarm Unit
                Column(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.occupied.withValues(alpha: 0.15),
                          border: Border.all(color: AppColors.occupied, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.occupied.withValues(alpha: 0.4),
                              blurRadius: 36,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          size: 72,
                          color: AppColors.occupied,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "TIME'S UP!",
                      style: GoogleFonts.orbitron(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      room.roomName,
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${room.equipmentType} • ${customer?.name ?? "Guest Player"}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isPaused
                              ? AppColors.paused.withValues(alpha: 0.6)
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPaused ? Icons.pause_circle_outline : Icons.all_inclusive,
                            size: 16,
                            color: isPaused ? AppColors.paused : AppColors.available,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPaused
                                ? 'Timer PAUSED at scheduled limit'
                                : 'Free Style (Overtime is ticking)',
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isPaused ? AppColors.paused : AppColors.available,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Bottom Action Buttons
                Column(
                  children: [
                    // Action 1: Free Style / Start Overtime
                    SizedBox(
                      width: double.infinity,
                      child: NeonButton(
                        label: 'FREE STYLE (START OVERTIME)',
                        icon: Icons.all_inclusive,
                        color: AppColors.available,
                        height: 50,
                        fontSize: 14,
                        onPressed: _handleFreeStyle,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Action 2 & 3: Extend or End Session
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            label: 'EXTEND TIME',
                            icon: Icons.more_time,
                            color: AppColors.primary,
                            height: 46,
                            fontSize: 13,
                            onPressed: _handleExtend,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NeonButton(
                            label: 'END SESSION',
                            icon: Icons.stop_circle_outlined,
                            color: AppColors.occupied,
                            height: 46,
                            fontSize: 13,
                            onPressed: _handleEndSession,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Action 4: Dismiss / Silence Alarm
                    TextButton.icon(
                      onPressed: _stopAndDismiss,
                      icon: const Icon(Icons.volume_off, color: AppColors.textMuted, size: 18),
                      label: Text(
                        'SILENCE / DISMISS ALARM',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
