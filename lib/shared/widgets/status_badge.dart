import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final bool isFullWidth;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status.toUpperCase()) {
      AppConstants.statusAvailable => ('AVAILABLE', AppColors.available),
      AppConstants.statusOccupied => ('OCCUPIED', AppColors.occupied),
      AppConstants.statusEndingSoon => ('ENDING SOON', AppColors.endingSoon),
      AppConstants.statusPaused => ('PAUSED', AppColors.paused),
      AppConstants.statusMaintenance => ('MAINTENANCE', AppColors.maintenance),
      AppConstants.paymentPaid => ('PAID', AppColors.available),
      AppConstants.paymentUnpaid => ('UNPAID', AppColors.occupied),
      _ => (status, AppColors.textSecondary),
    };

    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: isFullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.8),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
