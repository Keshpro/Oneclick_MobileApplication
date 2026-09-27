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
