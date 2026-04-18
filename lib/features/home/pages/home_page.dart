import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:Reflections/core/constants/app_strings.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/features/activity/pages/archive_page.dart';
import 'package:Reflections/features/home/presentation/controller/home_controller.dart';
import 'package:Reflections/features/profile/presentation/pages/profile_page.dart';
import 'package:Reflections/features/search/pages/search_page.dart';
import 'package:Reflections/shared/widgets/note_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    // The 4 tab bodies — IndexedStack keeps state alive
    final List<Widget> tabs = [
      _NotesTab(controller: controller),
      const SearchPage(),
      const ArchivePage(),
      const SettingsPage(),
    ];

    return Obx(() {
      final index = controller.selectedNavIndex.value;
      return Scaffold(
        backgroundColor: AppColors.background,
        drawer: _FolderDrawer(controller: controller),
        body: IndexedStack(index: index, children: tabs),

        // ─── FAB (only on Home tab) ────────────────────────────────────
        floatingActionButton: index == 0
            ? FloatingActionButton(
                onPressed: controller.navigateToAddNote,
                tooltip: 'New Note',
                child: Icon(Icons.edit_rounded, size: 22.r),
              )
            : null,

        // ─── Bottom Nav ────────────────────────────────────────────────
        bottomNavigationBar: _HomeBottomNav(
          currentIndex: index,
          onTap: controller.changeNavIndex,
        ),
      );
    });
  }
}

// ─── Notes Tab ─────────────────────────────────────────────────────────────
class _NotesTab extends StatelessWidget {
  final HomeController controller;
  const _NotesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _HomeAppBar(),
          SizedBox(height: 4.h),
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
                          SizedBox(height: 16.h),
                          Text(
                            controller.selectedFolder.value == 'All'
                                ? AppStrings.homeTitle
                                : controller.selectedFolder.value,
                            style: AppFontManager.displayLarge.copyWith(
                              fontSize: 28.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            controller.selectedFolder.value == 'All'
                                ? AppStrings.homeSubtitle
                                : 'Notes in ${controller.selectedFolder.value}',
                            style: AppFontManager.bodyMedium,
                          ),
                          SizedBox(height: 28.h),
                        ],
                      ),
                    ),
                  ),
                  if (controller.filteredNotes.isEmpty)
                    SliverFillRemaining(
                      child: _EmptyState(
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
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── App Bar ───────────────────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              padding: EdgeInsets.all(4.r),
              color: Colors.transparent,
              child: Icon(
                Icons.menu_rounded,
                color: AppColors.primaryDark,
                size: 24.r,
              ),
            ),
          ),
          const Spacer(),
          Text(AppStrings.appName, style: AppFontManager.appTitle),
          const Spacer(),
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryXLight, width: 1.5),
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.primaryDark,
              size: 20.r,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Navigation ─────────────────────────────────────────────────────
class _HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _HomeBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.home_outlined,
              isSelected: currentIndex == 0,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.search_rounded,
              isSelected: currentIndex == 1,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.archive_outlined,
              isSelected: currentIndex == 2,
            ),
            label: 'Archive',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.settings_outlined,
              isSelected: currentIndex == 3,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _NavIcon({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(isSelected ? 6.r : 4.r),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        icon,
        color: isSelected ? AppColors.primaryDark : AppColors.textHint,
        size: 22.r,
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAction;
  const _EmptyState({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_note_rounded,
                color: AppColors.primaryXLight,
                size: 32.r,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppStrings.homeEmpty,
              textAlign: TextAlign.center,
              style: AppFontManager.bodyMedium,
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Text(
                  AppStrings.homeEmptyAction,
                  style: AppFontManager.buttonSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Drawer ────────────────────────────────────────────────────────────────
class _FolderDrawer extends StatelessWidget {
  final HomeController controller;
  const _FolderDrawer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Account Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(32.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: AppColors.primaryMedium,
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 30.r,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Reflections',
                    style: AppFontManager.displayMedium.copyWith(
                      fontSize: 24.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? 'User Account',
                    style: AppFontManager.bodySmall.copyWith(
                      color: AppColors.primaryDark.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Folders',
                style: AppFontManager.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 10.h),

            Expanded(
              child: Obx(() {
                final selected = controller.selectedFolder.value;
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  children: [
                    _DrawerTile(
                      title: 'All Notes',
                      icon: Icons.all_inbox_rounded,
                      isSelected: selected == 'All',
                      onTap: () {
                        controller.selectFolder('All');
                        Scaffold.of(context).closeDrawer();
                      },
                    ),
                    SizedBox(height: 8.h),
                    ...controller.folders.map((folder) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _DrawerTile(
                          title: folder,
                          icon: Icons.folder_outlined,
                          isSelected: selected == folder,
                          onTap: () {
                            controller.selectFolder(folder);
                            Scaffold.of(context).closeDrawer();
                          },
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),

            Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: GestureDetector(
                onTap: () {
                  Scaffold.of(context).closeDrawer();
                  _showCreateFolderDialog(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.create_new_folder_outlined,
                        color: AppColors.primaryDark,
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'New Folder',
                        style: AppFontManager.buttonSmall.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final tc = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: AppColors.surface,
        title: Text('New Folder', style: AppFontManager.headlineMedium),
        content: TextField(
          controller: tc,
          autofocus: true,
          style: AppFontManager.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Folder name...',
            hintStyle: AppFontManager.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryMedium),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppFontManager.bodyMedium),
          ),
          TextButton(
            onPressed: () {
              final name = tc.text.trim();
              if (name.isNotEmpty) {
                controller.createFolder(name);
              }
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Create',
              style: AppFontManager.link.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMedium : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.primaryDark,
              size: 20.r,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: AppFontManager.bodyMedium.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
