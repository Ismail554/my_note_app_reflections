import 'package:Reflections/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_strings.dart';
import 'package:Reflections/core/providers/splash_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    // Initialize the splash timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashProvider>().initialize();
    });

    // Fade + scale in for logo/text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    // Dots pulse animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ─── App Icon ────────────────────────────────────────────
                Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: isDark ? AppColors.accentLight : AppColors.primaryDark,
                      size: 36.r,
                    ),
                  ),
                ),
                AppSpacing.h28,

                // ─── App Name ─────────────────────────────────────────────
                Text(
                  AppStrings.appName,
                  style: AppFontManager.displayMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                AppSpacing.h10,

                // ─── Tagline ──────────────────────────────────────────────
                Text(
                  AppStrings.appTagline,
                  style: AppFontManager.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                AppSpacing.h56,
                // ─── Animated Loading Dots ────────────────────────────────
                _AnimatedDots(controller: _dotsController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            // Stagger each dot
            final delay = i * 0.33;
            final value = ((controller.value - delay).clamp(0.0, 1.0));
            final opacity = 0.3 + (0.7 * value);
            final scale = 0.6 + (0.4 * value);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.accentLight : AppColors.primaryMedium,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
