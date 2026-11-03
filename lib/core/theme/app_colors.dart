import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Gaming Palette
  static const Color background = Color(0xFF0B0F14);
  static const Color surface = Color(0xFF151D27);
  static const Color surfaceElevated = Color(0xFF1E293B);
  static const Color cardBorder = Color(0xFF2A3749);

  // Semantic Status Colors
  static const Color available = Color(0xFF16E58B);     // Neon Green
  static const Color occupied = Color(0xFFFF4058);      // Neon Red
  static const Color endingSoon = Color(0xFFFFB547);    // Amber / Neon Orange
  static const Color paused = Color(0xFF438DFF);        // Neon Blue
  static const Color maintenance = Color(0xFF6B7280);   // Neutral Grey

  // Brand Accents
  static const Color primary = Color(0xFF8B5CF6);       // Electric Violet
  static const Color primaryGlow = Color(0x668B5CF6);
  static const Color secondary = Color(0xFF06B6D4);     // Cyber Cyan
  static const Color accent = Color(0xFFF43F5E);

  // Typography
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFF929CAA);
  static const Color textMuted = Color(0xFF64748B);

  // Indicators
  static const Color error = Color(0xFFFF4058);
  static const Color success = Color(0xFF16E58B);
  static const Color warning = Color(0xFFFFB547);
  static const Color info = Color(0xFF38BDF8);

  // Card Overlays
  static const Color glassFill = Color(0xCC151D27);
  static const Color glassBorder = Color(0x338B5CF6);
}
