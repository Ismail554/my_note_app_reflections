import 'package:Reflections/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/shared/widgets/note_card.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final archivedList = noteProvider.archivedNotes;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Archive', style: AppFontManager.displayMedium),
                  AppSpacing.h4,
                  Text(
                    'Notes you\'ve set aside for later.',
                    style: AppFontManager.bodySmall,
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: AppColors.divider),

            // ─── Content ─────────────────────────────────────────────────
            Expanded(
              child: Builder(builder: (context) {
                if (noteProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryMedium,
                    ),
                  );
                }

                if (archivedList.isEmpty) {
                  return _ArchiveEmptyState();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 16.h,
                    bottom: 100.h, // Space for frosted floating bottom nav!
                  ),
                  itemCount: archivedList.length,
                  itemBuilder: (context, index) {
                    final note = archivedList[index];
                    return Dismissible(
                      key: Key(note.id),
                      direction: DismissDirection.horizontal,
                      background: _DeleteBackground(),
                      secondaryBackground: _UnarchiveBackground(),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          noteProvider.archiveNote(note.id, false);
                        } else {
                          noteProvider.deletePermanently(note.id);
                        }
                      },
                      child: NoteCard(note: note),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────
class _ArchiveEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.h,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.archive_outlined,
                color: AppColors.primaryXLight,
                size: 32.sp,
              ),
            ),
            AppSpacing.h16,
            Text(
              'Archive is empty',
              style: AppFontManager.headlineMedium.copyWith(fontSize: 18.sp),
            ),
            AppSpacing.h8,
            Text(
              'Notes you archive will\nappear here.',
              textAlign: TextAlign.center,
              style: AppFontManager.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Swipe Background ─────────────────────────────────────────────────────
class _UnarchiveBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.w),
      decoration: BoxDecoration(
        color: AppColors.primaryMedium,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.unarchive_rounded, color: AppColors.white, size: 22.sp),
          AppSpacing.h4,
          Text(
            'Restore',
            style: AppFontManager.caption.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 20.w),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_forever_rounded,
            color: AppColors.white,
            size: 22.sp,
          ),
          AppSpacing.h4,
          Text(
            'Delete Forever',
            style: AppFontManager.caption.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
