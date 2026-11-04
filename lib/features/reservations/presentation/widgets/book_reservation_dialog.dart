import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../../rooms/providers/room_provider.dart';
import '../../providers/reservation_provider.dart';

class BookReservationDialog extends ConsumerStatefulWidget {
  final Room? initialRoom;

  const BookReservationDialog({
    super.key,
    this.initialRoom,
  });

  @override
  ConsumerState<BookReservationDialog> createState() => _BookReservationDialogState();
}

class _BookReservationDialogState extends ConsumerState<BookReservationDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? _selectedRoomId;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _durationMinutes = 60;
  bool _isSubmitting = false;
  String? _conflictError;

  @override
  void initState() {
    super.initState();
    _selectedRoomId = widget.initialRoom?.id;
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    // Suggest 30 minutes in the future
    final suggested = now.add(const Duration(minutes: 30));
    _selectedTime = TimeOfDay(hour: suggested.hour, minute: suggested.minute - (suggested.minute % 15));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      setState(() => _conflictError = 'Please select a room');
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    setState(() {
      _isSubmitting = true;
      _conflictError = null;
    });

    try {
      final repo = ref.read(reservationRepositoryProvider);
      await repo.createReservation(
        roomId: _selectedRoomId!,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        reservedFor: scheduledDateTime,
        durationMinutes: _durationMinutes,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reservation confirmed for ${_nameController.text.trim()}!',
              style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _conflictError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeRoomsAsync = ref.watch(activeRoomsProvider);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.event_available, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BOOK RESERVATION',
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            'Advance slot booking with conflict detection',
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
                const SizedBox(height: 20),

                // Conflict Banner
                if (_conflictError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _conflictError!,
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Room Selector
                Text(
                  'SELECT ROOM / CONSOLE *',
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                activeRoomsAsync.when(
                  loading: () => const LinearProgressIndicator(color: AppColors.primary),
                  error: (e, _) => Text('Error loading rooms: $e', style: const TextStyle(color: AppColors.error)),
                  data: (rooms) {
                    if (rooms.isEmpty) {
                      return Text('No rooms available', style: GoogleFonts.rajdhani(color: AppColors.textMuted));
                    }
                    if (_selectedRoomId == null || !rooms.any((r) => r.id == _selectedRoomId)) {
                      _selectedRoomId = rooms.first.id;
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedRoomId,
                      dropdownColor: AppColors.surfaceElevated,
                      style: GoogleFonts.rajdhani(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.cardBorder),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: rooms.map((room) {
                        return DropdownMenuItem<String>(
                          value: room.id,
                          child: Text(
                            '${room.roomName} (${room.equipmentType}) • ${AppConstants.currencySymbol}${room.hourlyRate.toStringAsFixed(0)}/hr',
                            style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedRoomId = val;
                          _conflictError = null;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Customer Name
                Text(
                  'CUSTOMER NAME *',
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.rajdhani(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter gamer or group name',
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted, size: 20),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Customer name is required' : null,
                ),
                const SizedBox(height: 14),

                // Customer Phone
                Text(
                  'PHONE NUMBER (OPTIONAL)',
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.rajdhani(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. 9876543210',
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textMuted, size: 20),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date & Time Selectors Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DATE',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      dateFormat.format(_selectedDate),
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'START TIME',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedTime.format(context),
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Duration Selector Chips
                Text(
                  'DURATION',
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
                  children: [30, 60, 90, 120, 180].map((mins) {
                    final isSelected = _durationMinutes == mins;
                    final label = mins < 60 ? '${mins}m' : '${mins ~/ 60}h${mins % 60 > 0 ? " ${mins % 60}m" : ""}';
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      labelStyle: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : AppColors.textSecondary,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceElevated,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _durationMinutes = mins;
                          _conflictError = null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Notes
                Text(
                  'NOTES (OPTIONAL)',
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  style: GoogleFonts.rajdhani(color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. Birthday tournament, multiplayer request',
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    NeonButton(
                      label: _isSubmitting ? 'CHECKING...' : 'CONFIRM BOOKING',
                      color: AppColors.primary,
                      onPressed: _isSubmitting ? () {} : _submit,
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
