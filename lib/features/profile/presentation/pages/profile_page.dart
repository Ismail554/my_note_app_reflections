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
import 'package:Reflections/features/profile/presentation/widgets/edit_profile_sheet.dart';
import 'package:Reflections/features/profile/presentation/widgets/change_password_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showEditProfile(BuildContext context, SettingsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(controller: controller),
    );
  }

  void _showChangePassword(BuildContext context, SettingsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangePasswordSheet(controller: controller),
    );
  }

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
            Obx(() => Text('settings'.tr, style: AppFontManager.displayMedium)),
            AppSpacing.h4,
            Obx(() => Text(
              'settingsSubtitle'.tr,
              style: AppFontManager.bodySmall,
            )),
            AppSpacing.h28,

            // ─── Profile Card ─────────────────────────────────────────────
            GestureDetector(
              onTap: () => _showEditProfile(context, controller),
              child: Obx(
                () => ProfileCard(
                  name: controller.displayName.value,
                  email: controller.email.value,
                ),
              ),
            ),
            AppSpacing.h28,

            // ─── Account Section ──────────────────────────────────────────
            Obx(() => SectionLabel(label: 'account'.tr)),
            AppSpacing.h10,
            Obx(() => SettingsTile(
              icon: Icons.person_outline_rounded,
              label: 'editProfile'.tr,
              onTap: () => _showEditProfile(context, controller),
            )),
            Obx(() => SettingsTile(
              icon: Icons.lock_outline_rounded,
              label: 'changePassword'.tr,
              onTap: () => _showChangePassword(context, controller),
            )),

            AppSpacing.h24,

            // ─── Preferences Section ──────────────────────────────────────
            Obx(() => SectionLabel(label: 'preferences'.tr)),
            AppSpacing.h10,
            Obx(
              () => ToggleTile(
                icon: Icons.notifications_outlined,
                label: 'notifications'.tr,
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
              ),
            ),
            Obx(
              () => ToggleTile(
                icon: Icons.save_outlined,
                label: 'autoSaveDrafts'.tr,
                value: controller.autoSaveEnabled.value,
                onChanged: controller.toggleAutoSave,
              ),
            ),
            Obx(
              () => SettingsTile(
                icon: Icons.language_rounded,
                label: 'language'.tr,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.currentLanguage.value,
                      style: AppFontManager.bodyMedium.copyWith(
                        color: AppColors.primaryMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.w6,
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textHint,
                      size: 14.r,
                    ),
                  ],
                ),
                onTap: () => _showLanguageDialog(context, controller),
              ),
            ),

            AppSpacing.h24,

            // ─── Info Section ─────────────────────────────────────────────
            Obx(() => SectionLabel(label: 'more'.tr)),
            AppSpacing.h10,
            Obx(() {
              final count = Get.isRegistered<HomeController>()
                  ? Get.find<HomeController>().notes.length
                  : 0;
              return InfoTile(
                icon: Icons.edit_note_rounded,
                label: 'totalNotes'.tr,
                value: '$count',
              );
            }),
            Obx(() => SettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'aboutReflections'.tr,
              onTap: () => _showAboutDialog(context),
            )),

            AppSpacing.h28,

            // ─── Logout ───────────────────────────────────────────────────
            Obx(() => LogoutButton(onTap: controller.logout)),
            AppSpacing.h40,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => Obx(
        () => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: AppColors.surface,
          title: Text('selectLanguage'.tr, style: AppFontManager.headlineMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('English', style: AppFontManager.bodyMedium),
                trailing: controller.currentLanguage.value == 'English'
                    ? const Icon(Icons.check, color: AppColors.primaryMedium)
                    : null,
                onTap: () {
                  controller.changeLanguage('en');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Español', style: AppFontManager.bodyMedium),
                trailing: controller.currentLanguage.value == 'Español'
                    ? const Icon(Icons.check, color: AppColors.primaryMedium)
                    : null,
                onTap: () {
                  controller.changeLanguage('es');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
