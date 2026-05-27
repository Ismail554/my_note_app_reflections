import 'package:flutter/material.dart';

/// Ritualz-inspired dual palette: dark-first, warm orange accent, minimal contrast.
class AppColors {
  AppColors._();

  // ─── Accent (Shared) ────────────────────────────────────────────────────
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF9A6C);
  static const Color accentSurface = Color(0x1AFF6B35); // 10% accent

  // ─── Heatmap Levels ─────────────────────────────────────────────────────
  static const Color heatmap0 = Color(0xFF1A1A1A); // empty (dark)
  static const Color heatmap1 = Color(0xFF2D4A3E);
  static const Color heatmap2 = Color(0xFF3D7A5A);
  static const Color heatmap3 = Color(0xFF4CAF6E);
  static const Color heatmap4 = Color(0xFF6FCF8D);

  static const Color heatmap0Light = Color(0xFFEEEEEE); // empty (light)
  static const Color heatmap1Light = Color(0xFFB8DFCA);
  static const Color heatmap2Light = Color(0xFF7BC9A0);
  static const Color heatmap3Light = Color(0xFF4CAF6E);
  static const Color heatmap4Light = Color(0xFF2E8B4E);

  // ─── Streak ─────────────────────────────────────────────────────────────
  static const Color streakFire = Color(0xFFFF6B35);

  // ─── Priority ───────────────────────────────────────────────────────────
  static const Color priorityLow = Color(0xFF6BCB77);
  static const Color priorityMedium = Color(0xFFFFD93D);
  static const Color priorityHigh = Color(0xFFFF6B6B);

  // ─── Status ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF6E);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFB74D);

  // ═══════════════════════════════════════════════════════════════════════
  //  DARK PALETTE
  // ═══════════════════════════════════════════════════════════════════════

  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF242424);
  static const Color darkCard = Color(0xFF1E1E1E);

  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextMuted = Color(0xFF707070);
  static const Color darkTextHint = Color(0xFF505050);

  static const Color darkDivider = Color(0xFF2A2A2A);
  static const Color darkInputBorder = Color(0xFF333333);
  static const Color darkInputFill = Color(0xFF1A1A1A);

  // ═══════════════════════════════════════════════════════════════════════
  //  LIGHT PALETTE
  // ═══════════════════════════════════════════════════════════════════════

  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F0F0);
  static const Color lightCard = Color(0xFFFFFFFF);

  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF555555);
  static const Color lightTextMuted = Color(0xFF999999);
  static const Color lightTextHint = Color(0xFFBBBBBB);

  static const Color lightDivider = Color(0xFFE5E5E5);
  static const Color lightInputBorder = Color(0xFFDDDDDD);
  static const Color lightInputFill = Color(0xFFF5F5F5);

  // ─── Neutral ──────────────────────────────────────────────────────────
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // ═══════════════════════════════════════════════════════════════════════
  //  LEGACY ALIASES (for gradual migration of old pages)
  // ═══════════════════════════════════════════════════════════════════════
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color surfaceVariant = lightSurfaceVariant;
  static const Color primaryDark = accent;
  static const Color primaryMedium = accent;
  static const Color primarySurface = accentSurface;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;
  static const Color textHint = lightTextHint;
  static const Color textOnPrimary = white;
  static const Color divider = lightDivider;
  static const Color inputBorder = lightInputBorder;
  static const Color inputFill = lightInputFill;
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color primaryLight = accentSurface;
  static const Color primaryXLight = Color(0xFFFFF3E0);
  static const Color cardBackground = lightCard;
  static const Color chipBackground = Color(0xFFF5F5F5);
  static const Color chipBorder = Color(0xFFE0E0E0);
}