import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_font_manager.dart';

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════
  //  DARK THEME (Default — Ritualz inspired)
  // ═══════════════════════════════════════════════════════════════════════
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          primary: AppColors.accent,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.accentSurface,
          onPrimaryContainer: AppColors.accent,
          secondary: AppColors.accentLight,
          onSecondary: AppColors.black,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          surfaceContainerHighest: AppColors.darkSurfaceVariant,
          onSurfaceVariant: AppColors.darkTextSecondary,
          outline: AppColors.darkInputBorder,
          error: AppColors.error,
          onError: AppColors.white,
          shadow: Color(0x40000000),
        ),
        textTheme: _buildTextTheme(Brightness.dark),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: AppColors.transparent,
          centerTitle: false,
          titleTextStyle: AppFontManager.headingLarge.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: AppColors.darkBackground,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
        elevatedButtonTheme: _elevatedButton(Brightness.dark),
        textButtonTheme: _textButton(),
        outlinedButtonTheme: _outlinedButton(Brightness.dark),
        inputDecorationTheme: _inputDecoration(Brightness.dark),
        cardTheme: _card(Brightness.dark),
        floatingActionButtonTheme: _fab(),
        bottomNavigationBarTheme: _bottomNav(Brightness.dark),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkDivider,
          thickness: 0.5,
          space: 0.5,
        ),
        switchTheme: _switchTheme(Brightness.dark),
        chipTheme: _chipTheme(Brightness.dark),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkCard,
          contentTextStyle: AppFontManager.bodyMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  // ═══════════════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          brightness: Brightness.light,
          primary: AppColors.accent,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.accentSurface,
          onPrimaryContainer: AppColors.accent,
          secondary: AppColors.accentLight,
          onSecondary: AppColors.black,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,
          surfaceContainerHighest: AppColors.lightSurfaceVariant,
          onSurfaceVariant: AppColors.lightTextSecondary,
          outline: AppColors.lightInputBorder,
          error: AppColors.error,
          onError: AppColors.white,
          shadow: Color(0x1A000000),
        ),
        textTheme: _buildTextTheme(Brightness.light),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: AppColors.transparent,
          centerTitle: false,
          titleTextStyle: AppFontManager.headingLarge.copyWith(
            color: AppColors.lightTextPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.lightBackground,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
        elevatedButtonTheme: _elevatedButton(Brightness.light),
        textButtonTheme: _textButton(),
        outlinedButtonTheme: _outlinedButton(Brightness.light),
        inputDecorationTheme: _inputDecoration(Brightness.light),
        cardTheme: _card(Brightness.light),
        floatingActionButtonTheme: _fab(),
        bottomNavigationBarTheme: _bottomNav(Brightness.light),
        dividerTheme: const DividerThemeData(
          color: AppColors.lightDivider,
          thickness: 0.5,
          space: 0.5,
        ),
        switchTheme: _switchTheme(Brightness.light),
        chipTheme: _chipTheme(Brightness.light),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.lightTextPrimary,
          contentTextStyle: AppFontManager.bodyMedium.copyWith(
            color: AppColors.lightBackground,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  // ═══════════════════════════════════════════════════════════════════════
  //  SHARED COMPONENT THEMES
  // ═══════════════════════════════════════════════════════════════════════

  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return TextTheme(
      displayLarge: AppFontManager.displayLarge.copyWith(color: primary),
      displayMedium: AppFontManager.displayMedium.copyWith(color: primary),
      displaySmall: AppFontManager.displayMedium.copyWith(color: primary),
      headlineLarge: AppFontManager.headingLarge.copyWith(color: primary),
      headlineMedium: AppFontManager.headingMedium.copyWith(color: primary),
      headlineSmall: AppFontManager.headingMedium.copyWith(color: primary),
      titleLarge: AppFontManager.headingLarge.copyWith(color: primary),
      titleMedium: AppFontManager.headingMedium.copyWith(color: primary),
      titleSmall: AppFontManager.bodyLarge.copyWith(color: primary, fontWeight: FontWeight.w500),
      bodyLarge: AppFontManager.bodyLarge.copyWith(color: secondary),
      bodyMedium: AppFontManager.bodyMedium.copyWith(color: secondary),
      bodySmall: AppFontManager.bodySmall.copyWith(color: muted),
      labelLarge: AppFontManager.labelMedium.copyWith(color: secondary, fontWeight: FontWeight.w600),
      labelMedium: AppFontManager.labelMedium.copyWith(color: muted),
      labelSmall: AppFontManager.caption.copyWith(color: muted),
    );
  }

  static ElevatedButtonThemeData _elevatedButton(Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
        elevation: 0,
        shadowColor: AppColors.transparent,
        minimumSize: Size(double.infinity, 52.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        textStyle: AppFontManager.buttonLarge,
      ),
    );
  }

  static TextButtonThemeData _textButton() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: AppFontManager.buttonSmall,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButton(Brightness brightness) {
    final borderColor = brightness == Brightness.dark
        ? AppColors.darkInputBorder
        : AppColors.lightInputBorder;
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: BorderSide(color: borderColor, width: 1),
        minimumSize: Size(double.infinity, 48.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        textStyle: AppFontManager.buttonLarge,
      ),
    );
  }

  static InputDecorationTheme _inputDecoration(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final fill = isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final border = isDark ? AppColors.darkInputBorder : AppColors.lightInputBorder;
    final hint = isDark ? AppColors.darkTextHint : AppColors.lightTextHint;

    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      hintStyle: AppFontManager.bodyMedium.copyWith(color: hint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  static CardThemeData _card(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? AppColors.darkCard
        : AppColors.lightCard;
    return CardThemeData(
      color: color,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  static FloatingActionButtonThemeData _fab() {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  static BottomNavigationBarThemeData _bottomNav(Brightness brightness) {
    final bg = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final unselected = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;

    return BottomNavigationBarThemeData(
      backgroundColor: bg,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: unselected,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    );
  }

  static SwitchThemeData _switchTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.accent;
        return isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.accentSurface;
        return isDark ? AppColors.darkDivider : AppColors.lightDivider;
      }),
    );
  }

  static ChipThemeData _chipTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ChipThemeData(
      backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      selectedColor: AppColors.accentSurface,
      labelStyle: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      side: BorderSide.none,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    );
  }
}
