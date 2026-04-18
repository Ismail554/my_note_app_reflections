import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppFontManager {
  // ─── Font Families ───────────────────────────────────────────────────────
  static const String serif = 'Georgia';
  static const String sansSerif = 'sans-serif';

  // ─── Display (Serif — used for "Thoughts", "Begin.", "Reflections") ──────
  static TextStyle get displayLarge => TextStyle(
        fontFamily: serif,
        fontWeight: FontWeight.w700,
        fontSize: 48.sp,
        color: AppColors.textPrimary,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: serif,
        fontWeight: FontWeight.w700,
        fontSize: 36.sp,
        color: AppColors.primaryDark,
        height: 1.15,
        letterSpacing: -0.3,
      );

  static TextStyle get appTitle => TextStyle(
        fontFamily: serif,
        fontWeight: FontWeight.w700,
        fontSize: 20.sp,
        color: AppColors.primaryDark,
        letterSpacing: 0.3,
      );

  // ─── Headline (Note card titles) ─────────────────────────────────────────
  static TextStyle get headlineLarge => TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22.sp,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18.sp,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  // ─── Body ────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        color: AppColors.textSecondary,
        height: 1.6,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
        color: AppColors.textSecondary,
        height: 1.55,
      );

  static TextStyle get bodySmall => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 13.sp,
        color: AppColors.textMuted,
        height: 1.5,
      );

  // ─── Label / Caption ─────────────────────────────────────────────────────
  static TextStyle get labelMedium => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12.sp,
        color: AppColors.textMuted,
        letterSpacing: 0.2,
      );

  static TextStyle get caption => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12.sp,
        color: AppColors.textHint,
        height: 1.4,
      );

  // ─── Button ──────────────────────────────────────────────────────────────
  static TextStyle get buttonLarge => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
        color: AppColors.textOnPrimary,
        letterSpacing: 0.3,
      );

  static TextStyle get buttonSmall => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13.sp,
        color: AppColors.textOnPrimary,
        letterSpacing: 0.2,
      );

  // ─── Input / Placeholder ─────────────────────────────────────────────────
  static TextStyle get inputTitle => TextStyle(
        fontFamily: serif,
        fontWeight: FontWeight.w400,
        fontSize: 28.sp,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get inputTitleHint => TextStyle(
        fontFamily: serif,
        fontWeight: FontWeight.w400,
        fontSize: 28.sp,
        color: AppColors.textHint,
        height: 1.3,
      );

  static TextStyle get inputBody => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 15.sp,
        color: AppColors.textSecondary,
        height: 1.7,
      );

  static TextStyle get inputBodyHint => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 15.sp,
        color: AppColors.textHint,
        height: 1.7,
      );

  // ─── Subtitle / Tagline ─────────────────────────────────────────────────
  static TextStyle get subtitle => TextStyle(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
        color: AppColors.textMuted,
        height: 1.5,
      );

  static TextStyle get link => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
        color: AppColors.primaryMedium,
        decoration: TextDecoration.none,
      );
}
