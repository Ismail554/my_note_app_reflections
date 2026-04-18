import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/features/home/presentation/controller/home_controller.dart';
import 'package:Reflections/features/profile/presentation/controller/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          children: [
            SizedBox(height: 20.h),

            // ─── Page Title ───────────────────────────────────────────────
            Text('Settings', style: AppFontManager.displayMedium),
            SizedBox(height: 4.h),
            Text(
              'Manage your account and preferences.',
              style: AppFontManager.bodySmall,
            ),
            SizedBox(height: 28.h),

            // ─── Profile Card ─────────────────────────────────────────────
            Obx(
              () => _ProfileCard(
                name: controller.displayName.value,
                email: controller.email.value,
              ),
            ),
            SizedBox(height: 28.h),

            // ─── Account Section ──────────────────────────────────────────
            _SectionLabel(label: 'Account'),
            SizedBox(height: 10.h),
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              label: 'Edit Profile',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.lock_outline_rounded,
              label: 'Change Password',
              onTap: () {},
            ),

            SizedBox(height: 24.h),

            // ─── Preferences Section ──────────────────────────────────────
            _SectionLabel(label: 'Preferences'),
            SizedBox(height: 10.h),
            Obx(
              () => _ToggleTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
              ),
            ),
            Obx(
              () => _ToggleTile(
                icon: Icons.save_outlined,
                label: 'Auto-save drafts',
                value: controller.autoSaveEnabled.value,
                onChanged: controller.toggleAutoSave,
              ),
            ),

            SizedBox(height: 24.h),

            // ─── Info Section ─────────────────────────────────────────────
            _SectionLabel(label: 'More'),
            SizedBox(height: 10.h),
            Obx(() {
              final count = Get.isRegistered<HomeController>()
                  ? Get.find<HomeController>().notes.length
                  : 0;
              return _InfoTile(
                icon: Icons.edit_note_rounded,
                label: 'Total Notes',
                value: '$count',
              );
            }),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'About Reflections',
              onTap: () => _showAboutDialog(context),
            ),

            SizedBox(height: 28.h),

            // ─── Logout ───────────────────────────────────────────────────
            _LogoutButton(onTap: controller.logout),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: AppColors.surface,
        title: Text('Reflections', style: AppFontManager.headlineMedium),
        content: Text(
          'Version 1.0.0\n\nThe quiet curator for your thoughts.\n\nA minimalist notes app designed for capturing ideas and reflections.',
          style: AppFontManager.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: AppFontManager.link),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Card ──────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileCard({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryXLight, width: 2),
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.primaryDark,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppFontManager.headlineMedium.copyWith(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  email,
                  style: AppFontManager.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Edit arrow
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textHint,
            size: 14.r,
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ─────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppFontManager.caption.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryMedium,
      ),
    );
  }
}

// ─── Settings Tile ─────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 18.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: AppFontManager.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textHint,
              size: 14.r,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle Tile ───────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 18.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              label,
              style: AppFontManager.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryDark,
            activeTrackColor: AppColors.primarySurface,
            inactiveThumbColor: AppColors.textHint,
            inactiveTrackColor: AppColors.surfaceVariant,
          ),
        ],
      ),
    );
  }
}

// ─── Info Tile ─────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 18.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              label,
              style: AppFontManager.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              value,
              style: AppFontManager.labelMedium.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Logout Button ─────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(color: AppColors.error.withAlpha(60), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 18.r),
            SizedBox(width: 8.w),
            Text(
              'Sign Out',
              style: AppFontManager.buttonLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: AppColors.surface,
        title: Text('Sign Out?', style: AppFontManager.headlineMedium),
        content: Text(
          'You will be returned to the login screen.',
          style: AppFontManager.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppFontManager.bodyMedium),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onTap();
            },
            child: Text(
              'Sign Out',
              style: AppFontManager.link.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
