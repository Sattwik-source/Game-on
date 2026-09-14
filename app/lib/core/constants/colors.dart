import 'package:flutter/material.dart';

/// Modern, minimalistic color palette for GameOn
/// Clean dark base with subtle, professional accents
class AppColors {
  AppColors._();

  // ── Background layers ────────────────────────────────────────
  static const bg        = Color(0xFF0a0b0f); // Deep dark base
  static const bg2       = Color(0xFF13151a); // Slightly elevated
  static const bg3       = Color(0xFF1a1d24); // Card backgrounds
  static const bgElevated = Color(0xFF212530); // Hover/elevated states

  // ── Surface & Borders ────────────────────────────────────────
  static const surface   = Color(0xFF13151a);
  static const surface2  = Color(0xFF1a1d24);
  static const surfaceHover = Color(0xFF1a1f27); // Subtle hover elevation

  static const border    = Color(0x0DFFFFFF); // Subtle border
  static const border2   = Color(0x14FFFFFF); // Slightly more visible
  static const borderHover = Color(0x1FFFFFFF); // Hover border

  // ── Primary Accents (Dark Gray) ────────────────────────────
  static const primary   = Color(0xFF6b7280); // Dark gray for better contrast
  static const primaryLight = Color(0xFF9ca3af);
  static const primaryDark = Color(0xFF4b5563);

  // ── Secondary Accents (Sky Blue) ─────────────────────────────
  static const secondary = Color(0xFF0ea5e9); // Sky blue (used sparingly)
  static const secondaryLight = Color(0xFF38bdf8);
  static const secondaryDark = Color(0xFF0284c7);

  // ── Success (Emerald) ────────────────────────────────────────
  static const success   = Color(0xFF10b981); // Emerald green
  static const successLight = Color(0xFF34d399);
  static const successDark = Color(0xFF059669);

  // ── Status Colors ────────────────────────────────────────────
  static const warning   = Color(0xFFf59e0b); // Amber
  static const danger    = Color(0xFFef4444); // Red
  static const error     = Color(0xFFef4444); // Error red

  // ── Text Colors ──────────────────────────────────────────────
  static const text      = Color(0xFFF0F0FF);
  static const textSecondary = Color(0xFFa0a5b8);
  static const muted     = Color(0xFF8890B0);
  static const muted2    = Color(0xFF6b7280);

  // ── Neutral Gray Scale ───────────────────────────────────────
  static const gray50    = Color(0xFFFAFAFA);
  static const gray100   = Color(0xFFF3F4F6);
  static const gray200   = Color(0xFFE5E7EB);
  static const gray300   = Color(0xFFD1D5DB);
  static const gray400   = Color(0xFF9CA3AF);
  static const gray500   = Color(0xFF6B7280);
  static const gray600   = Color(0xFF4B5563);
  static const gray700   = Color(0xFF374151);
  static const gray800   = Color(0xFF1F2937);
  static const gray900   = Color(0xFF111827);

  // ── Gradients ────────────────────────────────────────────────
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1a1f27), bg, bg2],
  );

  // ── Utility Methods ──────────────────────────────────────────
  /// Get accent color for sync status
  static Color syncStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return success;
      case SyncStatus.syncing:
        return secondary;
      case SyncStatus.error:
        return danger;
      case SyncStatus.pending:
        return warning;
    }
  }

  /// Get subtle shadow for depth (not glow)
  static BoxShadow subtleShadow({double blur = 8, double spread = 0}) {
    return BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: blur,
      spreadRadius: spread,
    );
  }
}

/// Sync status enum for color mapping
enum SyncStatus { synced, syncing, error, pending }
