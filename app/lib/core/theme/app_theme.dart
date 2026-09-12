import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

/// Central ThemeData for GameOn. Modern gaming launcher aesthetic
/// with dark base, orange primary, cyan secondary, lime success accents.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: AppColors.bg,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: AppColors.surfaceHover,
      dividerColor: AppColors.border,
      iconTheme: const IconThemeData(color: AppColors.muted, size: 18),

      // ── Elevated Button Theme ────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5),
          shadowColor: Colors.transparent,
        ),
      ),

      // ── Outlined Button Theme ────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.border2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // ── Text Button Theme ────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.text,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),

      // ── Input Decoration Theme ───────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.muted2, fontSize: 13),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
      ),

      // ── Card Theme ───────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // ── Progress Indicator Theme ─────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.surface,
        linearTrackColor: AppColors.surface,
      ),

      // ── Chip Theme ───────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.text, fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      // ── List Tile Theme ──────────────────────────────────────
      listTileTheme: ListTileThemeData(
        textColor: AppColors.text,
        iconColor: AppColors.muted,
        tileColor: AppColors.surface,
        selectedTileColor: AppColors.surfaceHover,
      ),
    );
  }

  /// Helper to create button with glow effect
  static ButtonStyle glowyButton({
    required Color backgroundColor,
    required Color glowColor,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: padding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: Colors.transparent,
    );
  }

  /// Helper to create card with hover effect
  static BoxDecoration hoverableCard({
    bool hovered = false,
    Color glowColor = AppColors.primary,
  }) {
    return BoxDecoration(
      color: hovered ? AppColors.surfaceHover : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: hovered ? glowColor : AppColors.border,
        width: hovered ? 1.5 : 1,
      ),
      boxShadow: hovered
          ? [
              BoxShadow(
                color: glowColor.withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ]
          : null,
    );
  }
}
