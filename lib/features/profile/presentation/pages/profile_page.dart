import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/features/home/presentation/controller/home_controller.dart';
import 'package:Reflections/features/profile/presentation/controller/settings_controller.dart';
import 'package:Reflections/features/profile/presentation/widgets/info_tile.dart';
import 'package:Reflections/features/profile/presentation/widgets/logout_button.dart';
import 'package:Reflections/features/profile/presentation/widgets/profile_card.dart';
import 'package:Reflections/features/profile/presentation/widgets/section_label.dart';
import 'package:Reflections/features/profile/presentation/widgets/settings_tile.dart';
import 'package:Reflections/features/profile/presentation/widgets/toggle_tile.dart';

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
            AppSpacing.h20,

            // ─── Page Title ───────────────────────────────────────────────
            Text('Settings', style: AppFontManager.displayMedium),
            AppSpacing.h4,
            Text(
              'Manage your account and preferences.',
              style: AppFontManager.bodySmall,
            ),
            AppSpacing.h28,

            // ─── Profile Card ─────────────────────────────────────────────
            Obx(
              () => ProfileCard(
                name: controller.displayName.value,
                email: controller.email.value,
              ),
            ),
            AppSpacing.h28,

            // ─── Account Section ──────────────────────────────────────────
            SectionLabel(label: 'Account'),
            AppSpacing.h10,
            SettingsTile(
              icon: Icons.person_outline_rounded,
              label: 'Edit Profile',
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.lock_outline_rounded,
              label: 'Change Password',
              onTap: () {},
            ),

            AppSpacing.h24,

            // ─── Preferences Section ──────────────────────────────────────
            SectionLabel(label: 'Preferences'),
            AppSpacing.h10,
            Obx(
              () => ToggleTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
              ),
            ),
            Obx(
              () => ToggleTile(
                icon: Icons.save_outlined,
                label: 'Auto-save drafts',
                value: controller.autoSaveEnabled.value,
                onChanged: controller.toggleAutoSave,
              ),
            ),

            AppSpacing.h24,

            // ─── Info Section ─────────────────────────────────────────────
            SectionLabel(label: 'More'),
            AppSpacing.h10,
            Obx(() {
              final count = Get.isRegistered<HomeController>()
                  ? Get.find<HomeController>().notes.length
                  : 0;
              return InfoTile(
                icon: Icons.edit_note_rounded,
                label: 'Total Notes',
                value: '$count',
              );
            }),
            SettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'About Reflections',
              onTap: () => _showAboutDialog(context),
            ),

            AppSpacing.h28,

            // ─── Logout ───────────────────────────────────────────────────
            LogoutButton(onTap: controller.logout),
            AppSpacing.h40,
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
