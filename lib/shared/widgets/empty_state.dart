import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.edit_note_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = AppFontManager.bodyMedium.copyWith(
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );
    final circleColor = isDark 
        ? AppColors.darkSurfaceVariant 
        : AppColors.primaryGreen.withValues(alpha: 0.08);
    final iconColor = isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen;

    final buttonBgColor = isDark ? AppColors.mediumGreen : AppColors.primaryGreen;
    final buttonTextColor = isDark ? AppColors.darkBackground : AppColors.white;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 32.sp,
              ),
            ),
            AppSpacing.h20,
            Text(
              message,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.h20,
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: buttonBgColor,
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Text(
                    actionLabel!,
                    style: AppFontManager.buttonSmall.copyWith(
                      color: buttonTextColor,
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
