import 'package:flutter/material.dart';

/// Color Hunt palette: https://colorhunt.co/palette/34673979ae6f9fcb98f2edc2
/// Combined with deep forest backgrounds for premium Dark theme and warm linen-whites for Light theme.
class AppColors {
  AppColors._();

  // ─── Core Colors ────────────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF346739);    // #346739 - Deep Forest Green
  static const Color mediumGreen = Color(0xFF79AE6F);     // #79AE6F - Mid-tone Sage Green
  static const Color softGreen = Color(0xFF9FCB98);       // #9FCB98 - Soft Sage Green
  static const Color cream = Color(0xFFF2EDC2);           // #F2EDC2 - Warm Cream / Beige

  // ─── Accent (Shared) ────────────────────────────────────────────────────
  static const Color accent = primaryGreen;
  static const Color accentLight = mediumGreen;
  static const Color accentSurface = Color(0x1F346739);   // 12% opacity primary green

  // ─── Heatmap Levels (Green/Cream Gradient) ──────────────────────────────
  static const Color heatmap0 = Color(0xFF162518);        // empty (dark)
  static const Color heatmap1 = Color(0xFF233B27);
  static const Color heatmap2 = Color(0xFF346739);
  static const Color heatmap3 = Color(0xFF79AE6F);
  static const Color heatmap4 = Color(0xFF9FCB98);

  static const Color heatmap0Light = Color(0xFFEBE6D0);   // empty (light)
  static const Color heatmap1Light = Color(0xFFD6CFA2);
  static const Color heatmap2Light = Color(0xFF9FCB98);
  static const Color heatmap3Light = Color(0xFF79AE6F);
  static const Color heatmap4Light = Color(0xFF346739);

  // ─── Streak ─────────────────────────────────────────────────────────────
  static const Color streakFire = Color(0xFFE67E22);

  // ─── Priority ───────────────────────────────────────────────────────────
  static const Color priorityLow = Color(0xFF79AE6F);
  static const Color priorityMedium = Color(0xFFD4AC0D);
  static const Color priorityHigh = Color(0xFFC0392B);

  // ─── Status ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFC0392B);
  static const Color warning = Color(0xFFD35400);

  // ═══════════════════════════════════════════════════════════════════════
  //  DARK PALETTE
  // ═══════════════════════════════════════════════════════════════════════
  static const Color darkBackground = Color(0xFF111C12);   // Deepest forest green
  static const Color darkSurface = Color(0xFF1B2C1D);      // Dark forest card surface
  static const Color darkSurfaceVariant = Color(0xFF243B27);
  static const Color darkCard = Color(0xFF1B2C1D);

  static const Color darkTextPrimary = Color(0xFFF2EDC2);  // Beautiful warm cream text
  static const Color darkTextSecondary = Color(0xFFB5C2B6);
  static const Color darkTextMuted = Color(0xFF758A78);
  static const Color darkTextHint = Color(0xFF4C5D4D);

  static const Color darkDivider = Color(0xFF243B27);
  static const Color darkInputBorder = Color(0xFF2A472E);
  static const Color darkInputFill = Color(0xFF132215);

  // ═══════════════════════════════════════════════════════════════════════
  //  LIGHT PALETTE
  // ═══════════════════════════════════════════════════════════════════════
  static const Color lightBackground = Color(0xFFFAF9F4);  // Clean linen white
  static const Color lightSurface = Color(0xFFFFFFFF);     // Pure card white
  static const Color lightSurfaceVariant = Color(0xFFF2EDC2); // Soft cream accents
  static const Color lightCard = Color(0xFFFFFFFF);

  static const Color lightTextPrimary = Color(0xFF1E2F1F); // Ultra readable deep forest charcoal
  static const Color lightTextSecondary = Color(0xFF4C5D4D);
  static const Color lightTextMuted = Color(0xFF7B8A7C);
  static const Color lightTextHint = Color(0xFFA1AFA2);

  static const Color lightDivider = Color(0xFFE5DFCD);
  static const Color lightInputBorder = Color(0xFFD5CEB4);
  static const Color lightInputFill = Color(0xFFFAF9F4);

  // ─── Neutral ──────────────────────────────────────────────────────────
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // ═══════════════════════════════════════════════════════════════════════
  //  LEGACY ALIASES (backward compatibility mapping)
  // ═══════════════════════════════════════════════════════════════════════
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color surfaceVariant = lightSurfaceVariant;
  static const Color primaryDark = primaryGreen;
  static const Color primaryMedium = primaryGreen;
  static const Color primarySurface = accentSurface;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;
  static const Color textHint = lightTextHint;
  static const Color textOnPrimary = white;
  static const Color divider = lightDivider;
  static const Color inputBorder = lightInputBorder;
  static const Color inputFill = lightInputFill;
  static const Color errorLight = Color(0xFFFADBD8);
  static const Color primaryLight = accentSurface;
  static const Color primaryXLight = Color(0xFFFAF9F4);
  static const Color cardBackground = lightCard;
  static const Color chipBackground = Color(0xFFF2EDC2);
  static const Color chipBorder = Color(0xFFD5CEB4);
}