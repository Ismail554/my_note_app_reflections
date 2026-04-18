import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;

  const ProfileCard({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryXLight, width: 2),
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.primaryDark,
              size: 28.r,
            ),
          ),
          AppSpacing.w16,

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppFontManager.headlineMedium.copyWith(
                    fontSize: 16.sp,
                  ),
                ),
                AppSpacing.h2,
                Text(
                  email,
                  style: AppFontManager.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppSpacing.w8,

          // Edit arrow
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textHint,
            size: 14.r,
          ),
        ],
      ),
    );
  }
}
