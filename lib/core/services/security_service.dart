import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../theme/app_colors.dart';
import '../../shared/widgets/neon_button.dart';

final securityServiceProvider = Provider<SecurityService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SecurityService(db);
});

class SecurityService {
  final AppDatabase _db;
  static const String _pinKey = 'security_pin_hash';
  static const String _pinSalt = 'atom_security_salt_v1_';

  SecurityService(this._db);

  String _hash(String pin) {
    final bytes = utf8.encode('$_pinSalt$pin');
    return base64UrlEncode(bytes);
  }

  Future<bool> isPinEnabled() async {
    final entry = await (_db.select(_db.appSettings)..where((t) => t.key.equals(_pinKey))).getSingleOrNull();
    return entry != null && entry.value.isNotEmpty;
  }

  Future<bool> verifyPin(String enteredPin) async {
    final entry = await (_db.select(_db.appSettings)..where((t) => t.key.equals(_pinKey))).getSingleOrNull();
    if (entry == null || entry.value.isEmpty) {
      return true; // No PIN set
    }
    return entry.value == _hash(enteredPin.trim());
  }

  Future<void> setPin(String newPin) async {
    final hashed = _hash(newPin.trim());
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: _pinKey,
        value: hashed,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<bool> disablePin(String currentPin) async {
    final verified = await verifyPin(currentPin);
    if (!verified) return false;

    await (_db.delete(_db.appSettings)..where((t) => t.key.equals(_pinKey))).go();
    return true;
  }

  /// Requests PIN verification dialog if PIN is set; otherwise shows standard confirmation.
  Future<bool> authenticateAction(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'PROCEED',
    bool isDestructive = false,
  }) async {
    final pinActive = await isPinEnabled();
    if (!context.mounted) return false;

    if (!pinActive) {
      // Just standard confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDestructive ? AppColors.error.withValues(alpha: 0.5) : AppColors.cardBorder,
            ),
          ),
          title: Row(
            children: [
              Icon(
                isDestructive ? Icons.warning_amber_rounded : Icons.info_outline,
                color: isDestructive ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'CANCEL',
                style: GoogleFonts.rajdhani(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            NeonButton(
              label: confirmLabel,
              color: isDestructive ? AppColors.error : AppColors.primary,
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      );
      return confirmed ?? false;
    }

    // PIN is active: Prompt for PIN
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PinInputDialog(
        title: title,
        message: message,
        isDestructive: isDestructive,
        confirmLabel: confirmLabel,
        securityService: this,
      ),
    );

    return result ?? false;
  }
}

class _PinInputDialog extends StatefulWidget {
  final String title;
  final String message;
  final bool isDestructive;
  final String confirmLabel;
  final SecurityService securityService;

  const _PinInputDialog({
    required this.title,
    required this.message,
    required this.isDestructive,
    required this.confirmLabel,
    required this.securityService,
  });

  @override
  State<_PinInputDialog> createState() => _PinInputDialogState();
}

class _PinInputDialogState extends State<_PinInputDialog> {
  final _pinController = TextEditingController();
  String? _errorMessage;
  bool _isVerifying = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Please enter your Security PIN');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final valid = await widget.securityService.verifyPin(pin);
    if (!mounted) return;

    if (valid) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Incorrect PIN. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.isDestructive ? AppColors.error.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      title: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: widget.isDestructive ? AppColors.error : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title,
              style: GoogleFonts.orbitron(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: widget.isDestructive ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SECURITY PIN REQUIRED',
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              autofocus: true,
              style: GoogleFonts.orbitron(
                fontSize: 18,
                letterSpacing: 6,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '••••',
                counterText: '',
                prefixIcon: const Icon(Icons.key, color: AppColors.textMuted, size: 20),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: widget.isDestructive ? AppColors.error : AppColors.primary,
                  ),
                ),
              ),
              onSubmitted: (_) => _handleVerify(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.pop(context, false),
          child: Text(
            'CANCEL',
            style: GoogleFonts.rajdhani(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        NeonButton(
          label: _isVerifying ? 'VERIFYING...' : widget.confirmLabel,
          color: widget.isDestructive ? AppColors.error : AppColors.primary,
          onPressed: _isVerifying ? () {} : _handleVerify,
        ),
      ],
    );
  }
}
