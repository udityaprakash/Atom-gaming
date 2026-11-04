import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../providers/customer_provider.dart';

class AddEditCustomerDialog extends ConsumerStatefulWidget {
  final Customer? customer;

  const AddEditCustomerDialog({super.key, this.customer});

  @override
  ConsumerState<AddEditCustomerDialog> createState() => _AddEditCustomerDialogState();
}

class _AddEditCustomerDialogState extends ConsumerState<AddEditCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;
  bool _isSaving = false;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _notesController = TextEditingController(text: widget.customer?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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
            _isEditing ? Icons.edit_note : Icons.person_add,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            _isEditing ? 'EDIT CUSTOMER' : 'NEW CUSTOMER',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.rajdhani(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter customer name';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.rajdhani(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Mobile Number (Optional)',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: GoogleFonts.rajdhani(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Notes (Preferences, Gamer Tag, etc.)',
                  prefixIcon: Icon(Icons.notes_outlined, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        OutlinedButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('CANCEL', style: GoogleFonts.rajdhani(color: AppColors.textMuted)),
        ),
        NeonButton(
          label: _isSaving ? 'SAVING...' : (_isEditing ? 'UPDATE' : 'CREATE'),
          icon: Icons.check,
          color: AppColors.primary,
          height: 38,
          fontSize: 12,
          onPressed: _isSaving ? null : _saveCustomer,
        ),
      ],
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final repo = ref.read(customerRepositoryProvider);

    try {
      if (_isEditing) {
        await repo.updateCustomer(
          id: widget.customer!.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );
      } else {
        await repo.createCustomer(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Customer updated successfully!' : 'Customer registered successfully!',
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
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
