import 'package:flutter/material.dart';

// Colour palette for the Drunk & Drive module only.
//
// This is deliberately separate from the app-wide AppColors — this
// service has its own dark, road-safety themed look, distinct from the
// main dashboard's blue/purple palette.

class DrunkDriveColors {
  DrunkDriveColors._();

  static const background = Color(0xFF12161C); // asphalt
  static const surface = Color(0xFF1C222B);
  static const surfaceBorder = Color(0xFF2A3341);
  static const accent = Color(0xFFFFB020); // road-safety amber
  static const textPrimary = Colors.white;
  static const textMuted = Color(0xFF8A93A3);
  static const danger = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
}

/// Theme-aware colors for refreshed Drunk & Drive screens.
/// Legacy DrunkDriveColors constants are kept for compatibility while
/// remaining screens are migrated; do not delete them yet.
class DrunkDrivePalette {
  final Color background;
  final Color surface;
  final Color surfaceBorder;
  final Color accent;
  final Color textPrimary;
  final Color textMuted;
  final Color danger;
  final Color success;

  const DrunkDrivePalette({
    required this.background,
    required this.surface,
    required this.surfaceBorder,
    required this.accent,
    required this.textPrimary,
    required this.textMuted,
    required this.danger,
    required this.success,
  });

  factory DrunkDrivePalette.of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DrunkDrivePalette(
      background: dark ? const Color(0xFF0C1014) : const Color(0xFFF0FAF9),
      surface: dark ? const Color(0xFF171E24) : Colors.white,
      surfaceBorder: dark ? const Color(0xFF293640) : const Color(0xFFD9ECEA),
      accent: dark ? const Color(0xFF38C5CB) : const Color(0xFF087F8C),
      textPrimary: dark ? Colors.white : const Color(0xFF12343B),
      textMuted: dark ? const Color(0xFFB3C3C8) : const Color(0xFF587276),
      danger: const Color(0xFFDC2626),
      success: const Color(0xFF168653),
    );
  }
}
