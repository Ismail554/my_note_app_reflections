import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';

import 'package:Reflections/core/localization/app_translations.dart';

class NoteTextColorPickerSheet extends StatelessWidget {
  final void Function(String hex) onColorSelected;

  const NoteTextColorPickerSheet({
    super.key,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textColors = [
      {'name': 'Red', 'hex': '#EF5350', 'color': const Color(0xFFEF5350)},
      {'name': 'Green', 'hex': '#66BB6A', 'color': const Color(0xFF66BB6A)},
      {'name': 'Blue', 'hex': '#42A5F5', 'color': const Color(0xFF42A5F5)},
      {'name': 'Orange', 'hex': '#FFA726', 'color': const Color(0xFFFFA726)},
      {'name': 'Purple', 'hex': '#AB47BC', 'color': const Color(0xFFAB47BC)},
      {'name': 'Pink', 'hex': '#EC407A', 'color': const Color(0xFFEC407A)},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'textColor'.tr,
            style: AppFontManager.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.h16,
          SizedBox(
            height: 60.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: textColors.length,
              separatorBuilder: (context, index) => AppSpacing.w16,
              itemBuilder: (context, index) {
                final item = textColors[index];
                final color = item['color'] as Color;
                final hex = item['hex'] as String;

                return GestureDetector(
                  onTap: () {
                    onColorSelected(hex);
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
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
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
