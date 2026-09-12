import 'package:flutter/material.dart';

/// Modern gaming launcher color palette for GameOn
/// Dark base with vibrant orange, cyan, and lime accents
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
  static const surfaceHover = Color(0xFF212530);

  static const border    = Color(0x12FFFFFF);
  static const border2   = Color(0x1EFFFFFF);
  static const borderHover = Color(0x2DFFFFFF);

  // ── Primary Accents (Orange) ─────────────────────────────────
  static const primary   = Color(0xFFff6b35); // Vibrant orange
  static const primaryLight = Color(0xFFff8c5a);
  static const primaryDark = Color(0xFFe55a24);

  // ── Secondary Accents (Cyan) ─────────────────────────────────
  static const secondary = Color(0xFF00d9ff); // Vibrant cyan
  static const secondaryLight = Color(0xFF33e3ff);
  static const secondaryDark = Color(0xFF00a8cc);

  // ── Success (Lime) ───────────────────────────────────────────
  static const success   = Color(0xFF00ff88); // Bright lime
  static const successLight = Color(0xFF33ff99);
  static const successDark = Color(0xFF00cc6a);

  // ── Status Colors ────────────────────────────────────────────
  static const warning   = Color(0xFFffd600); // Yellow
  static const danger    = Color(0xFFff3366); // Red/Pink
  static const error     = Color(0xFFEF4444); // Error red

  // ── Text Colors ──────────────────────────────────────────────
  static const text      = Color(0xFFF0F0FF);
  static const textSecondary = Color(0xFFa0a5b8);
  static const muted     = Color(0xFF8890B0);
  static const muted2    = Color(0xFF6b7280);

  // ── Legacy Purple (for transitions) ──────────────────────────
  static const purple    = Color(0xFF7C3AED);
  static const purple2   = Color(0xFFA855F7);
  static const purple3   = Color(0xFFC084FC);
  static const purpleGlow = Color(0x307C3AED);

  // ── Gradients ────────────────────────────────────────────────
  static const orangeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, primaryLight],
  );

  static const cyanGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [secondary, secondaryLight],
  );

  static const limeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [success, successLight],
  );

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

  /// Get glow effect for accents
  static BoxShadow accentGlow(Color color, {double blur = 20, double spread = 10}) {
    return BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: blur,
      spreadRadius: spread,
    );
  }
}

/// Sync status enum for color mapping
enum SyncStatus { synced, syncing, error, pending }
