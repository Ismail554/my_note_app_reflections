import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/constants/app_strings.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              padding: EdgeInsets.all(4.r),
              color: Colors.transparent,
              child: Icon(
                Icons.menu_rounded,
                color: AppColors.primaryDark,
                size: 24.r,
              ),
            ),
          ),
          const Spacer(),
          Text(AppStrings.appName, style: AppFontManager.appTitle),
          const Spacer(),
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryXLight, width: 1.5),
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.primaryDark,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}
