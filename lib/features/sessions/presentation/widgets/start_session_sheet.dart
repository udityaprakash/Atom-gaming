import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../providers/session_provider.dart';

class StartSessionSheet extends ConsumerStatefulWidget {
  final Room room;

  const StartSessionSheet({super.key, required this.room});

  @override
  ConsumerState<StartSessionSheet> createState() => _StartSessionSheetState();
}

class _StartSessionSheetState extends ConsumerState<StartSessionSheet> {
  int _selectedDurationMinutes = 60; // Default 1 hour
  bool _isCustomDuration = false;
  int _customHours = 1;
  int _customMinutes = 0;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  late int _controllerCount;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controllerCount = widget.room.controllerCount;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _effectiveDurationMinutes =>
      _isCustomDuration ? (_customHours * 60 + _customMinutes) : _selectedDurationMinutes;

  double get _estimatedCharge {
    final hours = _effectiveDurationMinutes / 60.0;
    return (hours * widget.room.hourlyRate).roundToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expectedEndTime = now.add(Duration(minutes: _effectiveDurationMinutes));

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
        border: Border(
          top: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
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

            // Header: Room info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'START SESSION',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.available,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.room.roomName} • ${widget.room.equipmentType}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '${CurrencyFormatter.format(widget.room.hourlyRate)}/hr',
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Duration Presets
            Text(
              'SELECT DURATION',
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
                ...AppConstants.durationPresets.map((mins) {
                  final isSelected = !_isCustomDuration && _selectedDurationMinutes == mins;
                  final label = mins < 60
                      ? '$mins min'
                      : mins == 60
                          ? '1 hour'
                          : '${mins ~/ 60}h ${mins % 60 > 0 ? '${mins % 60}m' : ''}';
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
                        _isCustomDuration = false;
                        _selectedDurationMinutes = mins;
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
                      fontWeight: _isCustomDuration ? FontWeight.bold : FontWeight.w600,
                      color: _isCustomDuration ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  selected: _isCustomDuration,
                  onSelected: (_) {
                    setState(() {
                      _isCustomDuration = true;
                    });
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceElevated,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _isCustomDuration ? AppColors.primary : AppColors.cardBorder,
                    ),
                  ),
                  showCheckmark: false,
                ),
              ],
            ),

            if (_isCustomDuration) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _customHours,
                      decoration: const InputDecoration(labelText: 'Hours'),
                      items: List.generate(12, (i) => i).map((h) {
                        return DropdownMenuItem(value: h, child: Text('$h hr'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _customHours = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _customMinutes,
                      decoration: const InputDecoration(labelText: 'Minutes'),
                      items: [0, 15, 30, 45].map((m) {
                        return DropdownMenuItem(value: m, child: Text('$m min'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _customMinutes = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Optional Customer Information
            Text(
              'CUSTOMER INFORMATION (OPTIONAL)',
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone_outlined, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Session Notes (Optional)',
                prefixIcon: Icon(Icons.note_alt_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 16),

            // Real-time Price Preview Box
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
                        'Expected End Time',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        TimeFormatter.formatTime(expectedEndTime),
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
                        'Estimated Charge',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(_estimatedCharge),
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
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

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: NeonButton(
                label: _isSubmitting ? 'STARTING...' : 'CONFIRM & START SESSION',
                icon: Icons.flash_on,
                color: AppColors.available,
                height: 48,
                fontSize: 14,
                onPressed: _isSubmitting ? null : _handleStartSession,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStartSession() async {
    if (_effectiveDurationMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid duration!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.startSession(
        roomId: widget.room.id,
        durationMinutes: _effectiveDurationMinutes,
        customerName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        customerPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        playerCount: 1,
        controllerCount: _controllerCount,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session started for ${widget.room.roomName}!'),
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
