import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';

import 'package:Reflections/core/localization/app_translations.dart';

class NoteHighlightColorPickerSheet extends StatelessWidget {
  final ValueChanged<String> onHighlightSelected;

  const NoteHighlightColorPickerSheet({
    super.key,
    required this.onHighlightSelected,
  });

  @override
  Widget build(BuildContext context) {
    final highlightColors = [
      {'name': 'Yellow', 'hex': 'yellow', 'color': const Color(0xFFFFF9C4)},
      {'name': 'Green', 'hex': 'green', 'color': const Color(0xFFC8E6C9)},
      {'name': 'Blue', 'hex': 'blue', 'color': const Color(0xFFBBDEFB)},
      {'name': 'Pink', 'hex': 'pink', 'color': const Color(0xFFF8BBD0)},
      {'name': 'Orange', 'hex': 'orange', 'color': const Color(0xFFFFE0B2)},
      {'name': 'Red', 'hex': 'red', 'color': const Color(0xFFFFCDD2)},
      {'name': 'Purple', 'hex': 'purple', 'color': const Color(0xFFE1BEE7)},
      {'name': 'Teal', 'hex': 'teal', 'color': const Color(0xFFB2DFDB)},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'highlightColor'.tr,
            style: AppFontManager.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.h16,
          SizedBox(
            height: 60.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: highlightColors.length,
              separatorBuilder: (context, index) => AppSpacing.w16,
              itemBuilder: (context, index) {
                final item = highlightColors[index];
                final color = item['color'] as Color;
                final hex = item['hex'] as String;

                return GestureDetector(
                  onTap: () {
                    onHighlightSelected(hex);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.divider,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.border_color_rounded,
                        color: Colors.black87,
                        size: 20.sp,
                      ),
                    ),
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
