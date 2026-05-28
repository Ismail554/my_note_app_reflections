import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/core/providers/note_provider.dart';

class VersionHistorySheet extends StatelessWidget {
  final String currentNoteId;
  final Function(String title, String description) onRestore;

  const VersionHistorySheet({
    super.key,
    required this.currentNoteId,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.r),
      height: 0.6.sh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Version History',
                style: AppFontManager.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          AppSpacing.h12,
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: context.read<NoteProvider>().getNoteVersions(currentNoteId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 48.sp,
                          color: AppColors.divider,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'No previous versions found.',
                          style: AppFontManager.bodyMedium.copyWith(
                            color: AppColors.divider,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final versions = snapshot.data!;
                return ListView.builder(
                  itemCount: versions.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final version = versions[index];
                    final date = version['updatedAt'] as DateTime;
                    final formattedDate = DateFormat(
                      'MMM dd, yyyy • hh:mm a',
                    ).format(date);
                    final title = version['title'] as String;
                    final desc = version['description'] as String;
                    final wordCount = desc.trim().isEmpty
                        ? 0
                        : desc.trim().split(RegExp(r'\s+')).length;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: AppFontManager.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  title.isEmpty ? 'Untitled' : title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontManager.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                Text(
                                  '$wordCount words',
                                  style: AppFontManager.bodySmall.copyWith(
                                    fontSize: 10.sp,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            icon: const Icon(
                              Icons.restore_rounded,
                              size: 16,
                            ),
                            label: const Text('Restore'),
                            onPressed: () => onRestore(title, desc),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
