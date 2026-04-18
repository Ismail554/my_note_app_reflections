import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(color: AppColors.error.withAlpha(60), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 18.r),
            AppSpacing.w8,
            Text(
              'Sign Out',
              style: AppFontManager.buttonLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: AppColors.surface,

        title: Text('Sign Out?', style: AppFontManager.headlineMedium),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppFontManager.bodySmall,
        ),
        actions: [
          Row(
            mainAxisAlignment: .spaceAround,
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel', style: AppFontManager.bodyMedium),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onTap();
                },
                child: Text(
                  'Confirm',
                  style: AppFontManager.link.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
