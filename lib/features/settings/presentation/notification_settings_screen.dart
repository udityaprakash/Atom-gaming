import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/alarm_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../sessions/data/session_repository.dart';
import '../../sessions/presentation/screens/alarm_trigger_screen.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoOvertimeEnabled = false;
  bool _billOnPauseEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final alarmService = ref.read(alarmServiceProvider);
    final sound = await alarmService.isSoundEnabled();
    final vibration = await alarmService.isVibrationEnabled();
    final autoOvertime = await alarmService.isAutoOvertimeEnabled();
    final billOnPause = await alarmService.isBillOnPauseEnabled();

    if (mounted) {
      setState(() {
        _soundEnabled = sound;
        _vibrationEnabled = vibration;
        _autoOvertimeEnabled = autoOvertime;
        _billOnPauseEnabled = billOnPause;
        _isLoading = false;
      });
    }
  }

  void _triggerTestAlarmScreen() {
    final now = DateTime.now();
    final testSession = ActiveRoomSession(
      session: Session(
        id: 'test_alert_preview',
        status: AppConstants.sessionPaused,
        startedAt: now.subtract(const Duration(minutes: 60)),
        scheduledEndAt: now,
        billingPolicy: 'per_minute',
        totalDurationSeconds: 3600,
        totalAmount: 200.0,
        paymentStatus: AppConstants.paymentUnpaid,
        createdAt: now,
      ),
      segment: SessionSegment(
        id: 'test_seg_preview',
        sessionId: 'test_alert_preview',
        roomId: 'test_room_preview',
        startedAt: now.subtract(const Duration(minutes: 60)),
        hourlyRateSnapshot: 200.0,
        amount: 200.0,
      ),
      room: Room(
        id: 'test_room_preview',
        roomName: 'Console 01',
        equipmentType: 'PS5 Pro',
        controllerCount: 4,
        hourlyRate: 200.0,
        status: AppConstants.statusOccupied,
        createdAt: now,
        updatedAt: now,
      ),
      customer: Customer(
        id: 'test_cust_preview',
        name: 'Alex Gamer',
        createdAt: now,
        updatedAt: now,
      ),
    );

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => AlarmTriggerScreen(activeSession: testSession),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'NOTIFICATION & ALARMS',
            style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final alarmService = ref.read(alarmServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NOTIFICATION & ALARMS',
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
          _buildSectionHeader('ALARM CHANNELS & HARDWARE'),
          _buildSwitchTile(
            title: 'Sound Alarm (Buzzer)',
            subtitle: 'Looping digital alarm buzzer when session duration ends',
            value: _soundEnabled,
            onChanged: (val) async {
              setState(() => _soundEnabled = val);
              await alarmService.setSoundEnabled(val);
            },
            icon: Icons.volume_up,
          ),
          _buildSwitchTile(
            title: 'Vibration Alarm (Haptic Motor)',
            subtitle: 'Continuous repeating vibration pattern on time expiration',
            value: _vibrationEnabled,
            onChanged: (val) async {
              setState(() => _vibrationEnabled = val);
              await alarmService.setVibrationEnabled(val);
            },
            icon: Icons.vibration,
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('TIMER EXPIRY & PAUSE BILLING RULES'),
          _buildSwitchTile(
            title: 'Bill During Mid-Session Pause',
            subtitle: _billOnPauseEnabled
                ? 'ENABLED: Room hourly rate continues accruing even while session is paused.'
                : 'PAUSE IS FREE: Session billing freezes while paused. Paused time is not charged.',
            value: _billOnPauseEnabled,
            onChanged: (val) async {
              setState(() => _billOnPauseEnabled = val);
              await alarmService.setBillOnPauseEnabled(val);
            },
            icon: Icons.pause_circle_outline,
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            title: 'Auto-Overtime on Expiry',
            subtitle: _autoOvertimeEnabled
                ? 'ENABLED: Overtime timer starts ticking and billing automatically when time is reached.'
                : 'PAUSE WHEN FINISHED: Session stops billing at scheduled end time. Extra time is only billed if Free Style or Extend is chosen.',
            value: _autoOvertimeEnabled,
            onChanged: (val) async {
              setState(() => _autoOvertimeEnabled = val);
              await alarmService.setAutoOvertimeEnabled(val);
            },
            icon: Icons.timer_outlined,
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('HARDWARE & ALARM TEST'),
          Row(
            children: [
              Expanded(
                child: NeonButton(
                  label: 'TEST SOUND',
                  icon: Icons.music_note,
                  color: AppColors.secondary,
                  isOutlined: true,
                  height: 44,
                  onPressed: () async {
                    await alarmService.testSound();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeonButton(
                  label: 'TEST VIBRATION',
                  icon: Icons.vibration,
                  color: AppColors.primary,
                  isOutlined: true,
                  height: 44,
                  onPressed: () async {
                    await alarmService.testVibration();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: NeonButton(
              label: 'PREVIEW MORNING ALARM SCREEN',
              icon: Icons.notifications_active,
              color: AppColors.occupied,
              height: 48,
              fontSize: 13,
              onPressed: _triggerTestAlarmScreen,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: NeonButton(
              label: 'TEST NATIVE ALARM (LOCK SCREEN TEST)',
              icon: Icons.alarm,
              color: AppColors.accent,
              isOutlined: true,
              height: 44,
              fontSize: 13,
              onPressed: () async {
                await alarmService.testNativeAlarm();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Native alarm ringing in 1 second! Lock screen or background app now.',
                        style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      backgroundColor: AppColors.surfaceElevated,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Persistent Alarm System',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'When any room session expires, atom sounds a looping buzzer, vibrates continuously, and opens the full-screen Alarm Screen until you take action (Free Style, Extend, End, or Dismiss).',
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
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.rajdhani(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        secondary: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
