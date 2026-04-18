import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_font_manager.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primaryDark,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.primarySurface,
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.primaryMedium,
          onSecondary: AppColors.white,
          secondaryContainer: AppColors.chipBackground,
          onSecondaryContainer: AppColors.primaryDark,
          tertiary: AppColors.primaryLight,
          onTertiary: AppColors.white,
          error: AppColors.error,
          onError: AppColors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.surfaceVariant,
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.inputBorder,
          shadow: Color(0x1A1A5340),
        ),

        // ─── AppBar ──────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: AppFontManager.appTitle,
          iconTheme: const IconThemeData(color: AppColors.primaryDark),
          actionsIconTheme: const IconThemeData(color: AppColors.primaryDark),
        ),

        // ─── ElevatedButton ───────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            minimumSize: Size(double.infinity, 52.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.r),
            ),
            textStyle: AppFontManager.buttonLarge,
          ),
        ),

        // ─── TextButton ───────────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryMedium,
            textStyle: AppFontManager.link,
          ),
        ),

        // ─── InputDecoration ──────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          hintStyle: AppFontManager.bodyMedium.copyWith(color: AppColors.textHint),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: AppColors.primaryMedium, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),

        // ─── Card ─────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),

        // ─── FloatingActionButton ─────────────────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),

        // ─── BottomNavigationBar ──────────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: AppColors.textHint,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),

        // ─── Divider ──────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // ─── Text ─────────────────────────────────────────────────────────
        textTheme: TextTheme(
          displayLarge: AppFontManager.displayLarge,
          displayMedium: AppFontManager.displayMedium,
          headlineLarge: AppFontManager.headlineLarge,
          headlineMedium: AppFontManager.headlineMedium,
          bodyLarge: AppFontManager.bodyLarge,
          bodyMedium: AppFontManager.bodyMedium,
          bodySmall: AppFontManager.bodySmall,
          labelMedium: AppFontManager.labelMedium,
        ),
      );
}
