import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../providers/room_provider.dart';

class AddEditRoomDialog extends ConsumerStatefulWidget {
  final Room? roomToEdit;

  const AddEditRoomDialog({super.key, this.roomToEdit});

  @override
  ConsumerState<AddEditRoomDialog> createState() => _AddEditRoomDialogState();
}

class _AddEditRoomDialogState extends ConsumerState<AddEditRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _rateController;
  late final TextEditingController _descController;
  late String _equipmentType;
  late int _controllerCount;
  late String _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final r = widget.roomToEdit;
    _nameController = TextEditingController(text: r?.roomName ?? '');
    _rateController = TextEditingController(text: r != null ? r.hourlyRate.toInt().toString() : '150');
    _descController = TextEditingController(text: r?.description ?? '');
    _equipmentType = r?.equipmentType ?? AppConstants.equipmentTypes.first;
    _controllerCount = r?.controllerCount ?? 2;
    _status = r?.status ?? AppConstants.statusAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.roomToEdit != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit : Icons.add_circle,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            isEditing ? 'EDIT ROOM' : 'ADD NEW ROOM',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Room Name / Number *',
                    hintText: 'e.g. Room 01, VIP Lounge',
                    prefixIcon: Icon(Icons.meeting_room, size: 18),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Room name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Equipment Type
                DropdownButtonFormField<String>(
                  initialValue: AppConstants.equipmentTypes.contains(_equipmentType)
                      ? _equipmentType
                      : AppConstants.equipmentTypes.first,
                  decoration: const InputDecoration(
                    labelText: 'Equipment Type *',
                    prefixIcon: Icon(Icons.sports_esports, size: 18),
                  ),
                  dropdownColor: AppColors.surfaceElevated,
                  items: AppConstants.equipmentTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _equipmentType = val);
                  },
                ),
                const SizedBox(height: 12),

                // Controller Count & Hourly Rate Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _controllerCount,
                        decoration: const InputDecoration(
                          labelText: 'Controllers *',
                          prefixIcon: Icon(Icons.gamepad, size: 18),
                        ),
                        dropdownColor: AppColors.surfaceElevated,
                        items: [1, 2, 3, 4, 6, 8].map((c) {
                          return DropdownMenuItem(value: c, child: Text('$c'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _controllerCount = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _rateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rate (₹/hr) *',
                          prefixText: '₹ ',
                          prefixIcon: Icon(Icons.currency_rupee, size: 18),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final val = double.tryParse(v.trim());
                          if (val == null || val <= 0) return 'Invalid rate';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status if editing
                if (isEditing) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.info_outline, size: 18),
                    ),
                    dropdownColor: AppColors.surfaceElevated,
                    items: const [
                      DropdownMenuItem(
                        value: AppConstants.statusAvailable,
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.statusMaintenance,
                        child: Text('Maintenance'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.statusDeactivated,
                        child: Text('Deactivated'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Equipment Description / Notes
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Equipment Notes (Optional)',
                    hintText: 'e.g. 65" 4K OLED, 2 DualSense controllers',
                    prefixIcon: Icon(Icons.notes, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('CANCEL', style: GoogleFonts.rajdhani(color: AppColors.textSecondary)),
        ),
        NeonButton(
          label: _isSubmitting ? 'SAVING...' : (isEditing ? 'UPDATE' : 'CREATE ROOM'),
          icon: isEditing ? Icons.save : Icons.add,
          color: AppColors.primary,
          height: 38,
          fontSize: 12,
          onPressed: _isSubmitting ? null : _handleSave,
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final repo = ref.read(roomRepositoryProvider);
    final rate = double.parse(_rateController.text.trim());

    try {
      if (isEditing) {
        await repo.updateRoom(
          id: widget.roomToEdit!.id,
          roomName: _nameController.text.trim(),
          equipmentType: _equipmentType,
          controllerCount: _controllerCount,
          hourlyRate: rate,
          description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
          status: _status,
        );
      } else {
        await repo.createRoom(
          roomName: _nameController.text.trim(),
          equipmentType: _equipmentType,
          controllerCount: _controllerCount,
          hourlyRate: rate,
          description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Room updated successfully!' : 'Room created successfully!'),
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
