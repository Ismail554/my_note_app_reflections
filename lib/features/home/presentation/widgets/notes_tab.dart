import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:Reflections/core/constants/app_strings.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/features/home/presentation/controller/home_controller.dart';
import 'package:Reflections/shared/widgets/note_card.dart';
import 'package:Reflections/shared/widgets/empty_state.dart';
import 'package:Reflections/features/home/presentation/widgets/home_app_bar.dart';

class NotesTab extends StatelessWidget {
  final HomeController controller;
  const NotesTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const HomeAppBar(),
          AppSpacing.h4,
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryMedium,
                  ),
                );
              }

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
                            controller.selectedFolder.value == 'All'
                                ? AppStrings.homeTitle
                                : controller.selectedFolder.value,
                            style: AppFontManager.displayLarge.copyWith(
                              fontSize: 28.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          AppSpacing.h8,
                          Text(
                            controller.selectedFolder.value == 'All'
                                ? AppStrings.homeSubtitle
                                : 'Notes in ${controller.selectedFolder.value}',
                            style: AppFontManager.bodyMedium,
                          ),
                          AppSpacing.h28,
                        ],
                      ),
                    ),
                  ),
                  if (controller.filteredNotes.isEmpty)
                    SliverFillRemaining(
                      child: EmptyState(
                        message: AppStrings.homeEmpty,
                        actionLabel: AppStrings.homeEmptyAction,
                        onAction: controller.navigateToAddNote,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final note = controller.filteredNotes[index];
                          return NoteCard(
                            note: note,
                            onTap: () => controller.navigateToEditNote(note),
                          );
                        }, childCount: controller.filteredNotes.length),
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
