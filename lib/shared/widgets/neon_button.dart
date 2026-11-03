import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool isOutlined;
  final double height;
  final double fontSize;

  const NeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color = AppColors.primary,
    this.isOutlined = false,
    this.height = 42,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.8), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: Size(0, height),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: _buildChild(),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: color.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: fontSize + 3),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
