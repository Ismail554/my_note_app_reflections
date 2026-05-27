import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/shared/widgets/note_card.dart';
import 'package:Reflections/shared/widgets/empty_state.dart';
import 'package:Reflections/features/home/presentation/widgets/home_app_bar.dart';
import 'package:Reflections/core/utils/app_navigator.dart';
import 'package:Reflections/core/localization/app_translations.dart';

class NotesTab extends StatelessWidget {
  final NoteProvider provider;
  const NotesTab({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const HomeAppBar(),
          AppSpacing.h4,
          Expanded(
            child: Builder(builder: (context) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryMedium,
                  ),
                );
              }

              final notesList = provider.filteredNotes;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSpacing.h16,
                          Text(
                            provider.selectedFolder == 'All'
                                ? 'homeTitle'.tr
                                : provider.selectedFolder,
                            style: AppFontManager.displayLarge.copyWith(
                              fontSize: 28.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          AppSpacing.h8,
                          Text(
                            provider.selectedFolder == 'All'
                                ? 'homeSubtitle'.tr
                                : 'More in ${provider.selectedFolder}',
                            style: AppFontManager.bodyMedium,
                          ),
                          AppSpacing.h28,
                        ],
                      ),
                    ),
                  ),
                  if (notesList.isEmpty)
                    SliverFillRemaining(
                      child: EmptyState(
                        message: 'homeEmpty'.tr,
                        actionLabel: 'homeEmptyAction'.tr,
                        onAction: () => AppNavigator.goToAddNote(),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final note = notesList[index];
                          return NoteCard(
                            note: note,
                            onTap: () => AppNavigator.goToAddNote(note: note),
                          );
                        }, childCount: notesList.length),
                      ),
                    ),
                  SliverToBoxAdapter(child: AppSpacing.h96),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
