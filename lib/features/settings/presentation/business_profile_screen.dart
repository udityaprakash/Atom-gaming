import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neon_button.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _footerController = TextEditingController();

  TimeOfDay _openingTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 23, minute: 0);

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final db = ref.read(appDatabaseProvider);
    final settings = await db.select(db.appSettings).get();
    final map = {for (final s in settings) s.key: s.value};

    if (mounted) {
      setState(() {
        _nameController.text = map['store_name'] ?? 'atom Gaming Zone';
        _phoneController.text = map['store_phone'] ?? '';
        _addressController.text = map['store_address'] ?? '';
        _footerController.text = map['receipt_footer'] ?? 'Thank you for gaming with us! Visit again.';

        if (map['opening_hour'] != null && map['opening_minute'] != null) {
          _openingTime = TimeOfDay(
            hour: int.tryParse(map['opening_hour']!) ?? 10,
            minute: int.tryParse(map['opening_minute']!) ?? 0,
          );
        }
        if (map['closing_hour'] != null && map['closing_minute'] != null) {
          _closingTime = TimeOfDay(
            hour: int.tryParse(map['closing_hour']!) ?? 23,
            minute: int.tryParse(map['closing_minute']!) ?? 0,
          );
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();

    final updates = {
      'store_name': _nameController.text.trim(),
      'store_phone': _phoneController.text.trim(),
      'store_address': _addressController.text.trim(),
      'receipt_footer': _footerController.text.trim(),
      'opening_hour': _openingTime.hour.toString(),
      'opening_minute': _openingTime.minute.toString(),
      'closing_hour': _closingTime.hour.toString(),
      'closing_minute': _closingTime.minute.toString(),
    };

    for (final entry in updates.entries) {
      await db.into(db.appSettings).insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              key: entry.key,
              value: entry.value,
              updatedAt: now,
            ),
          );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Business profile updated successfully!',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickOpeningTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _openingTime,
    );
    if (picked != null) {
      setState(() => _openingTime = picked);
    }
  }

  Future<void> _pickClosingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _closingTime,
    );
    if (picked != null) {
      setState(() => _closingTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BUSINESS PROFILE',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STORE DETAILS (RECEIPT BRANDING)',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.rajdhani(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Store / Gaming Zone Name *',
                        prefixIcon: const Icon(Icons.storefront, color: AppColors.primary, size: 20),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Store name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.rajdhani(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Contact Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      style: GoogleFonts.rajdhani(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Store Address / Location',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _footerController,
                      maxLines: 2,
                      style: GoogleFonts.rajdhani(color: AppColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Receipt Footer Message',
                        prefixIcon: const Icon(Icons.notes, color: AppColors.primary, size: 20),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'OPERATING HOURS',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickOpeningTime,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'OPENING TIME',
                                    style: GoogleFonts.orbitron(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _openingTime.format(context),
                                    style: GoogleFonts.orbitron(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _pickClosingTime,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CLOSING TIME',
                                    style: GoogleFonts.orbitron(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _closingTime.format(context),
                                    style: GoogleFonts.orbitron(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: NeonButton(
                        label: _isSaving ? 'SAVING...' : 'SAVE BUSINESS PROFILE',
                        color: AppColors.primary,
                        height: 46,
                        onPressed: _isSaving ? null : _saveSettings,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
