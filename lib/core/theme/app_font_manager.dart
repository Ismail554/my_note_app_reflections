import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Minimal typography system using Inter via Google Fonts.
/// Colors are null so ThemeData text theme colors apply automatically.
class AppFontManager {
  AppFontManager._();

  // ─── Display (Hero text, page titles) ───────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 32.sp,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 24.sp,
        height: 1.2,
        letterSpacing: -0.3,
      );

  // ─── Heading (Section titles, card titles) ──────────────────────────────
  static TextStyle get headingLarge => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 20.sp,
        height: 1.25,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 17.sp,
        height: 1.3,
      );

  // ─── Body ──────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        height: 1.55,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 13.sp,
        height: 1.45,
      );

  // ─── Label / Caption ───────────────────────────────────────────────────
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 12.sp,
        letterSpacing: 0.3,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 11.sp,
        height: 1.4,
      );

  // ─── Button ────────────────────────────────────────────────────────────
  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonSmall => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 13.sp,
        letterSpacing: 0.2,
      );

  // ─── Input ─────────────────────────────────────────────────────────────
  static TextStyle get inputTitle => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 22.sp,
        height: 1.3,
      );

  static TextStyle get inputBody => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 15.sp,
        height: 1.65,
      );

  // ─── Stat number (large bold for streak counters) ──────────────────────
  static TextStyle get statNumber => GoogleFonts.inter(
        fontWeight: FontWeight.w800,
        fontSize: 36.sp,
        height: 1.0,
        letterSpacing: -1,
      );

  static TextStyle get statLabel => GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 11.sp,
        height: 1.3,
        letterSpacing: 0.5,
      );

  // ═══════════════════════════════════════════════════════════════════════
  //  LEGACY ALIASES (for gradual migration of old pages)
  // ═══════════════════════════════════════════════════════════════════════
  static TextStyle get headlineLarge => headingLarge;
  static TextStyle get headlineMedium => headingMedium;
  static TextStyle get appTitle => headingLarge;
  static TextStyle get subtitle => bodySmall.copyWith(fontStyle: FontStyle.italic);
  static TextStyle get link => bodyMedium.copyWith(
        color: const Color(0xFFFF6B35),
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.none,
      );
  static TextStyle get inputTitleHint => inputTitle.copyWith(color: const Color(0xFFBBBBBB));
  static TextStyle get inputBodyHint => inputBody.copyWith(color: const Color(0xFFBBBBBB));
}
