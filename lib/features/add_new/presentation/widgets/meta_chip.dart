import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';

class MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool hasCustomColor;
  final bool isDark;

  const MetaChip({
    super.key,
    required this.icon,
    required this.label,
    required this.hasCustomColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = hasCustomColor
        ? Colors.black.withValues(alpha: 0.05)
        : (isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant);

    final fg = hasCustomColor
        ? AppColors.lightTextSecondary
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return Container(
      padding: AppPadding.h10v6,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: hasCustomColor
              ? Colors.black.withValues(alpha: 0.08)
              : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: fg),
          AppSpacing.w6,
          Text(label, style: AppFontManager.labelMedium.copyWith(color: fg)),
        ],
      ),
    );
  }
}
