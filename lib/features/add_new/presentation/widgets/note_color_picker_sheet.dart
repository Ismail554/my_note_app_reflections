import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/core/localization/app_translations.dart';

class NoteColorPickerSheet extends StatelessWidget {
  final int selectedColor;
  final ValueChanged<int> onColorSelected;

  const NoteColorPickerSheet({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      {'name': 'Default', 'value': 0},
      {'name': 'Cream', 'value': 0xFFFDF6EC},
      {'name': 'Sage', 'value': 0xFFF0F4F1},
      {'name': 'Mist', 'value': 0xFFEDF4F9},
      {'name': 'Lavender', 'value': 0xFFF6F0F8},
      {'name': 'Blush', 'value': 0xFFFAF0F0},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'noteColor'.tr,
            style: AppFontManager.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.h16,
          SizedBox(
            height: 60.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length,
              separatorBuilder: (context, index) => AppSpacing.w16,
              itemBuilder: (context, index) {
                final colorItem = colors[index];
                final value = colorItem['value'] as int;
                final isSelected = selectedColor == value;

                return GestureDetector(
                  onTap: () {
                    onColorSelected(value);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: BoxDecoration(
                      color: value == 0
                          ? AppColors.cardBackground
                          : Color(value),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryMedium
                            : AppColors.divider,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: AppColors.primaryMedium,
                            size: 20.sp,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          AppSpacing.h12,
        ],
      ),
    );
  }
}
