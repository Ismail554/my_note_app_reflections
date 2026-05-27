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
    final hasCustomColor = note.colorValue != 0;
    final backgroundColor = hasCustomColor ? Color(note.colorValue) : AppColors.cardBackground;

    return Hero(
      tag: 'note_${note.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: double.maxFinite,
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.r),
              border: hasCustomColor
                  ? Border.all(color: Color(note.colorValue).withValues(alpha: 0.8), width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        note.title,
                        style: AppFontManager.headlineLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isPinned) ...[
                      AppSpacing.w8,
                      Icon(
                        Icons.push_pin_rounded,
                        size: 16.sp,
                        color: const Color(0xFFC6A052), // Gold pin accent
                      ),
                    ],
                  ],
                ),
                AppSpacing.h8,

                // Date chip
                DateChip(label: note.dateLabel),
                AppSpacing.h10,

                // Preview text
                if (note.preview.isNotEmpty)
                  Text(
                    note.preview,
                    style: AppFontManager.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
