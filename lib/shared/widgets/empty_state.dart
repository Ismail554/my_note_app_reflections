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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.h,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryXLight,
                size: 32.sp,
              ),
            ),
            AppSpacing.h20,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFontManager.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.h20,
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Text(
                    actionLabel!,
                    style: AppFontManager.buttonSmall,
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
