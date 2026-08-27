import 'package:flutter/material.dart';

/// Color palette matching the GameOn dark/purple design concept.
class AppColors {
  AppColors._();

  static const bg        = Color(0xFF07080F);
  static const bg2        = Color(0xFF0D0F1A);
  static const bg3        = Color(0xFF12152A);

  static const surface   = Color(0xFF161929);
  static const surface2  = Color(0xFF1C2035);

  static const border    = Color(0x12FFFFFF);
  static const border2   = Color(0x1EFFFFFF);

  static const purple    = Color(0xFF7C3AED);
  static const purple2   = Color(0xFFA855F7);
  static const purple3   = Color(0xFFC084FC);
  static const purpleGlow = Color(0x307C3AED);

  static const text      = Color(0xFFF0F0FF);
  static const muted     = Color(0xFF8890B0);
  static const muted2    = Color(0xFF4A5270);

  static const green     = Color(0xFF22C55E);
  static const amber     = Color(0xFFF59E0B);
  static const red       = Color(0xFFEF4444);
  static const blue      = Color(0xFF3B82F6);

  static const purpleGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purple, purple2],
  );

  static const heroRadial = RadialGradient(
    center: Alignment(0, 0.6),
    radius: 1.2,
    colors: [Color(0xFF2D1066), bg2, bg],
    stops: [0.0, 0.6, 1.0],
  );
}
