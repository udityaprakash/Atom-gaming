import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../data/session_repository.dart';
import '../../providers/session_provider.dart';

class ExtendSessionSheet extends ConsumerStatefulWidget {
  final ActiveRoomSession activeSession;

  const ExtendSessionSheet({super.key, required this.activeSession});

  @override
  ConsumerState<ExtendSessionSheet> createState() => _ExtendSessionSheetState();
}

class _ExtendSessionSheetState extends ConsumerState<ExtendSessionSheet> {
  int _selectedMinutes = 30;
  bool _isCustom = false;
  final _customMinutesController = TextEditingController(text: '45');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _customMinutesController.dispose();
    super.dispose();
  }

  int get _effectiveExtensionMinutes {
    if (_isCustom) {
      return int.tryParse(_customMinutesController.text.trim()) ?? 0;
    }
    return _selectedMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.activeSession.session;
    final room = widget.activeSession.room;
    final segment = widget.activeSession.segment;

    final baseTime = session.scheduledEndAt.isBefore(DateTime.now())
        ? DateTime.now()
        : session.scheduledEndAt;
    final newEndTime = baseTime.add(Duration(minutes: _effectiveExtensionMinutes));
    final estimatedExtraCharge =
        ((_effectiveExtensionMinutes / 60.0) * segment.hourlyRateSnapshot).roundToDouble();

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXTEND SESSION',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${room.roomName} • ${room.equipmentType}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${CurrencyFormatter.format(segment.hourlyRateSnapshot)}/hr',
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Extension Presets
            Text(
              'SELECT EXTENSION DURATION',
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...AppConstants.extensionPresets.map((mins) {
                  final isSelected = !_isCustom && _selectedMinutes == mins;
                  final label = mins < 60 ? '+$mins min' : '+1 hour';
                  return ChoiceChip(
                    label: Text(
                      label,
                      style: GoogleFonts.rajdhani(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _isCustom = false;
                        _selectedMinutes = mins;
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      ),
                    ),
                    showCheckmark: false,
                  );
                }),
                ChoiceChip(
                  label: Text(
                    'Custom',
                    style: GoogleFonts.rajdhani(
                      fontWeight: _isCustom ? FontWeight.bold : FontWeight.w600,
                      color: _isCustom ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  selected: _isCustom,
                  onSelected: (_) {
                    setState(() => _isCustom = true);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceElevated,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _isCustom ? AppColors.primary : AppColors.cardBorder,
                    ),
                  ),
                  showCheckmark: false,
                ),
              ],
            ),

            if (_isCustom) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customMinutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Extension Duration (Minutes)',
                  suffixText: 'minutes',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 16),

            // Preview Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Scheduled End Time',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        TimeFormatter.formatTime(newEndTime),
                        style: GoogleFonts.orbitron(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimated Extra Cost',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(estimatedExtraCharge),
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.available,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: NeonButton(
                label: _isSubmitting ? 'EXTENDING...' : 'CONFIRM EXTENSION (+${_effectiveExtensionMinutes}m)',
                icon: Icons.more_time,
                color: AppColors.primary,
                height: 48,
                fontSize: 14,
                onPressed: _isSubmitting ? null : _handleExtend,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExtend() async {
    final mins = _effectiveExtensionMinutes;
    if (mins <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select valid extension minutes!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.extendSession(
        sessionId: widget.activeSession.session.id,
        extensionMinutes: mins,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Session for ${widget.activeSession.room.roomName} extended by $mins minutes!',
            ),
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
