import 'package:Reflections/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/shared/models/note_model.dart';
import 'package:Reflections/shared/widgets/date_chip.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onTap;

  const NoteCard({super.key, required this.note, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        height: 130.h,
        constraints: BoxConstraints(maxHeight: 130.h),
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note.title,
              style: AppFontManager.headlineLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.h8,

            // Date chip
            DateChip(label: note.dateLabel),
            AppSpacing.h10,

            // Preview text
            if (note.preview.isNotEmpty)
              Expanded(
                child: Text(
                  note.preview,
                  style: AppFontManager.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
