import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/features/home/presentation/controller/home_controller.dart';

class FolderDrawer extends StatelessWidget {
  final HomeController controller;
  const FolderDrawer({super.key, required this.controller});

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
                  AppSpacing.h16,
                  Text(
                    'Reflections',
                    style: AppFontManager.displayMedium.copyWith(
                      fontSize: 24.sp,
                    ),
                  ),
                  AppSpacing.h4,
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

            AppSpacing.h20,
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
            AppSpacing.h10,
            Divider(height: 1, color: AppColors.divider),
            AppSpacing.h10,

            Expanded(
              child: Obx(() {
                final selected = controller.selectedFolder.value;
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  children: [
                    DrawerTile(
                      title: 'All Notes',
                      icon: Icons.all_inbox_rounded,
                      isSelected: selected == 'All',
                      onTap: () {
                        controller.selectFolder('All');
                        Scaffold.of(context).closeDrawer();
                      },
                    ),
                    AppSpacing.h8,
                    ...controller.folders.map((folder) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: DrawerTile(
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
                      AppSpacing.w8,
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
            AppSpacing.w14,
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
