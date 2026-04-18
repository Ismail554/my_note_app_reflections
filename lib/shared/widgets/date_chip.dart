
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_notes/core/theme/app_colors.dart';
import 'package:my_notes/core/theme/app_font_manager.dart';

class DateChip extends StatelessWidget {
  final String label;

  const DateChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.chipBorder, width: 0.8),
      ),
      child: Text(
        label,
        style: AppFontManager.labelMedium.copyWith(
          color: AppColors.primaryMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
