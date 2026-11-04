import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/security_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/neon_button.dart';

class ManageSecurityPinDialog extends ConsumerStatefulWidget {
  const ManageSecurityPinDialog({super.key});

  @override
  ConsumerState<ManageSecurityPinDialog> createState() => _ManageSecurityPinDialogState();
}

class _ManageSecurityPinDialogState extends ConsumerState<ManageSecurityPinDialog> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _isPinCurrentlyEnabled = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _checkPinStatus() async {
    final security = ref.read(securityServiceProvider);
    final enabled = await security.isPinEnabled();
    if (mounted) {
      setState(() {
        _isPinCurrentlyEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _savePin() async {
    final security = ref.read(securityServiceProvider);
    setState(() => _errorMessage = null);

    if (_isPinCurrentlyEnabled) {
      final currentPin = _currentPinController.text.trim();
      final valid = await security.verifyPin(currentPin);
      if (!valid) {
        setState(() => _errorMessage = 'Current PIN is incorrect.');
        return;
      }
    }

    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin.length < 4 || newPin.length > 6) {
      setState(() => _errorMessage = 'PIN must be between 4 and 6 digits.');
      return;
    }

    if (newPin != confirmPin) {
      setState(() => _errorMessage = 'New PIN and Confirm PIN do not match.');
      return;
    }

    await security.setPin(newPin);
    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Security PIN ${_isPinCurrentlyEnabled ? "updated" : "enabled"} successfully!',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _removePin() async {
    final security = ref.read(securityServiceProvider);
    final currentPin = _currentPinController.text.trim();
    if (currentPin.isEmpty) {
      setState(() => _errorMessage = 'Please enter your current PIN to remove protection.');
      return;
    }

    final success = await security.disablePin(currentPin);
    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Security PIN protection disabled.',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
    } else {
      setState(() => _errorMessage = 'Current PIN is incorrect.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      title: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isPinCurrentlyEnabled ? 'MANAGE SECURITY PIN' : 'SET SECURITY PIN',
              style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isPinCurrentlyEnabled
                        ? 'Protect sensitive operations like database restores, data resets, and room deletions.'
                        : 'Set a 4 to 6 digit security PIN to protect database restores and critical actions.',
                    style: GoogleFonts.rajdhani(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  if (_isPinCurrentlyEnabled) ...[
                    Text(
                      'CURRENT PIN',
                      style: GoogleFonts.orbitron(fontSize: 10, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _currentPinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: 'Enter current PIN',
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Text(
                    'NEW PIN (4-6 DIGITS)',
                    style: GoogleFonts.orbitron(fontSize: 10, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _newPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'Enter new PIN',
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'CONFIRM NEW PIN',
                    style: GoogleFonts.orbitron(fontSize: 10, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _confirmPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'Re-enter new PIN',
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.rajdhani(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
      actions: [
        if (_isPinCurrentlyEnabled)
          TextButton(
            onPressed: _removePin,
            child: Text(
              'REMOVE PIN',
              style: GoogleFonts.rajdhani(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        NeonButton(
          label: 'SAVE PIN',
          color: AppColors.primary,
          onPressed: _savePin,
        ),
      ],
    );
  }
}
