import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/core/providers/note_provider.dart';

class FolderDrawer extends StatelessWidget {
  const FolderDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final selected = noteProvider.selectedFolder;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final drawerBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final headerBg = isDark ? AppColors.darkSurfaceVariant : AppColors.accentSurface;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Account Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(32.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: isDark ? AppColors.accent : AppColors.primaryMedium,
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.white,
                      size: 30.sp,
                    ),
                  ),
                  AppSpacing.h16,
                  Text(
                    'Reflections',
                    style: AppFontManager.displayMedium.copyWith(
                      fontSize: 24.sp,
                      color: primaryTextColor,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? 'User Account',
                    style: AppFontManager.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.primaryGreen.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.h20,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Folders',
                style: AppFontManager.labelMedium.copyWith(
                  color: secondaryTextColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            AppSpacing.h10,
            Divider(height: 1, color: dividerColor),
            AppSpacing.h10,

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                children: [
                  DrawerTile(
                    title: 'All Notes',
                    icon: Icons.all_inbox_rounded,
                    isSelected: selected == 'All',
                    onTap: () {
                      noteProvider.selectFolder('All');
                      Scaffold.of(context).closeDrawer();
                    },
                  ),
                  AppSpacing.h8,
                  ...noteProvider.folders.map((folder) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: DrawerTile(
                        title: folder,
                        icon: Icons.folder_outlined,
                        isSelected: selected == folder,
                        onTap: () {
                          noteProvider.selectFolder(folder);
                          Scaffold.of(context).closeDrawer();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            Divider(height: 1, color: dividerColor),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: GestureDetector(
                onTap: () {
                  Scaffold.of(context).closeDrawer();
                  _showCreateFolderDialog(context, noteProvider);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.create_new_folder_outlined,
                        color: isDark ? AppColors.accentLight : AppColors.primaryGreen,
                        size: 20.sp,
                      ),
                      AppSpacing.w8,
                      Text(
                        'New Folder',
                        style: AppFontManager.buttonSmall.copyWith(
                          color: isDark ? AppColors.accentLight : AppColors.primaryGreen,
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

  void _showCreateFolderDialog(BuildContext context, NoteProvider noteProvider) {
    final tc = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        title: Text('New Folder', style: AppFontManager.headlineMedium.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        )),
        content: TextField(
          controller: tc,
          autofocus: true,
          style: AppFontManager.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Folder name...',
            hintStyle: AppFontManager.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isDark ? AppColors.accentLight : AppColors.primaryGreen),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppFontManager.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            )),
          ),
          TextButton(
            onPressed: () {
              final name = tc.text.trim();
              if (name.isNotEmpty) {
                noteProvider.createFolder(name);
              }
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Create',
              style: AppFontManager.link.copyWith(
                color: isDark ? AppColors.accentLight : AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? AppColors.primaryGreen : AppColors.softGreen.withValues(alpha: 0.3)) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen) 
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              size: 20.sp,
            ),
            AppSpacing.w14,
            Expanded(
              child: Text(
                title,
                style: AppFontManager.bodyMedium.copyWith(
                  color: isSelected 
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen) 
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
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
