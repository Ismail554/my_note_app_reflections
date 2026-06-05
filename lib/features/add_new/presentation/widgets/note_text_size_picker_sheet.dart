import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';

import 'package:Reflections/core/localization/app_translations.dart';

class NoteTextSizePickerSheet extends StatefulWidget {
  final double initialFontSize;
  final ValueChanged<double> onFontSizeChanged;

  const NoteTextSizePickerSheet({
    super.key,
    required this.initialFontSize,
    required this.onFontSizeChanged,
  });

  @override
  State<NoteTextSizePickerSheet> createState() => _NoteTextSizePickerSheetState();
}

class _NoteTextSizePickerSheetState extends State<NoteTextSizePickerSheet> {
  late double _bodyFontSize;

  @override
  void initState() {
    super.initState();
    _bodyFontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'textSizeScaling'.tr,
            style: AppFontManager.headlineMedium.copyWith(
              color: textPrimary,
            ),
          ),
          AppSpacing.h16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('A', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textSecondary)),
              Expanded(
                child: Slider(
                  value: _bodyFontSize,
                  min: 12.0,
                  max: 30.0,
                  divisions: 9,
                  activeColor: AppColors.primaryGreen,
                  inactiveColor: borderColor,
                  label: '${_bodyFontSize.toInt()} sp',
                  onChanged: (val) {
                    setState(() {
                      _bodyFontSize = val;
                    });
                    widget.onFontSizeChanged(val);
                  },
                ),
              ),
              Text('A', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: textPrimary)),
            ],
          ),
          AppSpacing.h8,
          Center(
            child: Text(
              '${'previewLabel'.tr}: ${_bodyFontSize.toInt()} sp',
              style: AppFontManager.bodyMedium.copyWith(
                fontSize: _bodyFontSize.sp,
                color: textPrimary,
              ),
            ),
          ),
          AppSpacing.h12,
        ],
      ),
    );
  }
}
