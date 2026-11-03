import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/alarm_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neon_button.dart';

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
  String _vibrationPattern = 'Pulse';
  String _repeatInterval = 'Every 30 seconds';
  String _snoozeDuration = '2 minutes';

  @override
  Widget build(BuildContext context) {
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
          _buildSectionHeader('ALARM CHANNELS'),
          _buildSwitchTile(
            title: 'Sound Alert',
            subtitle: 'Play audible alarm when session duration ends',
            value: _soundEnabled,
            onChanged: (val) => setState(() => _soundEnabled = val),
            icon: Icons.volume_up,
          ),
          _buildSwitchTile(
            title: 'Vibration Alert',
            subtitle: 'Trigger device haptic motor on time expiration',
            value: _vibrationEnabled,
            onChanged: (val) => setState(() => _vibrationEnabled = val),
            icon: Icons.vibration,
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('VIBRATION & TIMING PREFERENCES'),
          _buildDropdownTile(
            title: 'Vibration Pattern',
            value: _vibrationPattern,
            options: const ['Short', 'Pulse', 'Long', 'Continuous'],
            onChanged: (val) => setState(() => _vibrationPattern = val),
          ),
          _buildDropdownTile(
            title: 'Repeat Alert Interval',
            value: _repeatInterval,
            options: const ['Once', 'Every 30 seconds', 'Every minute'],
            onChanged: (val) => setState(() => _repeatInterval = val),
          ),
          _buildDropdownTile(
            title: 'Snooze Duration',
            value: _snoozeDuration,
            options: const ['1 minute', '2 minutes', '5 minutes'],
            onChanged: (val) => setState(() => _snoozeDuration = val),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('HARDWARE TEST'),
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
                    final alarmService = ref.read(alarmServiceProvider);
                    await alarmService.showImmediateAlert(
                      sessionId: 'test_sound',
                      roomName: 'Sound Test',
                      title: 'SOUND TEST',
                      body: 'Sound alert is functioning properly!',
                    );
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
                    final alarmService = ref.read(alarmServiceProvider);
                    await alarmService.triggerVibrationPattern(
                      _vibrationPattern == 'Short'
                          ? [0, 300]
                          : _vibrationPattern == 'Long'
                              ? [0, 1000]
                              : [0, 400, 200, 400, 200, 600],
                    );
                  },
                ),
              ),
            ],
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
                const Icon(Icons.battery_alert, color: AppColors.endingSoon, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Android Battery Optimization',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'To ensure alarms trigger on exact time while the device is locked, exempt atom from aggressive battery optimization in your device system settings.',
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
      padding: const EdgeInsets.only(bottom: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
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
                  style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox.shrink(),
            dropdownColor: AppColors.surface,
            items: options.map((opt) {
              return DropdownMenuItem(
                value: opt,
                child: Text(
                  opt,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ],
      ),
    );
  }
}
