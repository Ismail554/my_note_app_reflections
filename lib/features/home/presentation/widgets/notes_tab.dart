import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/shared/widgets/note_card.dart';
import 'package:Reflections/shared/widgets/empty_state.dart';
import 'package:Reflections/core/utils/app_navigator.dart';
import 'package:Reflections/core/localization/app_translations.dart';

class NotesTab extends StatefulWidget {
  final NoteProvider provider;
  const NotesTab({super.key, required this.provider});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> get _filteredNotes {
    final notes = widget.provider.filteredNotes;
    if (_searchQuery.isEmpty) return notes;
    final q = _searchQuery.toLowerCase();
    return notes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = widget.provider;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      provider.selectedFolder == 'All'
                          ? 'homeTitle'.tr
                          : provider.selectedFolder,
                      style: AppFontManager.displayMedium.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  // Archive button
                  IconButton(
                    onPressed: () {
                      // Toggle archive view via folder drawer
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(
                      Icons.folder_rounded,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Search Bar ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: AppFontManager.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20.sp,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: Icon(Icons.close_rounded, size: 18.sp),
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
            ),
          ),

          // ─── Folder Chips ────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: provider.folders.length + 1, // +1 for "All"
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final label = isAll ? 'All' : provider.folders[index - 1];
                  final isSelected = provider.selectedFolder == label;

                  return GestureDetector(
                    onTap: () => provider.selectFolder(label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        label,
                        style: AppFontManager.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 16.h)),

          // ─── Notes List ──────────────────────────────────────
          Builder(builder: (context) {
            if (provider.isLoading) {
              return SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              );
            }

            final notesList = _filteredNotes;

            if (notesList.isEmpty) {
              return SliverFillRemaining(
                child: EmptyState(
                  message: _searchQuery.isNotEmpty
                      ? 'No notes match your search.'
                      : 'homeEmpty'.tr,
                  actionLabel: 'homeEmptyAction'.tr,
                  onAction: () => AppNavigator.goToAddNote(),
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == notesList.length) {
                      return SizedBox(height: 100.h);
                    }
                    final note = notesList[index];
                    return NoteCard(
                      note: note,
                      onTap: () => AppNavigator.goToAddNote(note: note),
                    );
                  },
                  childCount: notesList.length + 1, // +1 for bottom padding
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
