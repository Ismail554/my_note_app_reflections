
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_notes/core/theme/app_colors.dart';
import 'package:my_notes/core/theme/app_font_manager.dart';

/// add note save button
class AppSaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppSaveButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isLoading ? AppColors.primaryLight : AppColors.primaryDark,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: isLoading
            ? SizedBox(
                width: 14.r,
                height: 14.r,
                child: const CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, color: AppColors.white, size: 14.r),
                  SizedBox(width: 4.w),
                  Text(
                    'Save',
                    style: AppFontManager.buttonSmall,
                  ),
                ],
              ),
      ),
    );
  }
}
