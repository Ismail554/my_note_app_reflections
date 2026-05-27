import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/core/providers/settings_provider.dart';
import 'package:Reflections/features/profile/presentation/widgets/info_tile.dart';
import 'package:Reflections/features/profile/presentation/widgets/logout_button.dart';
import 'package:Reflections/features/profile/presentation/widgets/profile_card.dart';
import 'package:Reflections/features/profile/presentation/widgets/section_label.dart';
import 'package:Reflections/features/profile/presentation/widgets/settings_tile.dart';
import 'package:Reflections/features/profile/presentation/widgets/toggle_tile.dart';
import 'package:Reflections/features/profile/presentation/widgets/edit_profile_sheet.dart';
import 'package:Reflections/features/profile/presentation/widgets/change_password_sheet.dart';
import 'package:Reflections/core/localization/app_translations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showEditProfile(BuildContext context, SettingsProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(provider: provider),
    );
  }

  void _showChangePassword(BuildContext context, SettingsProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangePasswordSheet(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final noteProvider = context.watch<NoteProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          children: [
            AppSpacing.h20,

            // ─── Page Title ───────────────────────────────────────────────
            Text('settings'.tr, style: AppFontManager.displayMedium),
            AppSpacing.h4,
            Text(
              'settingsSubtitle'.tr,
              style: AppFontManager.bodySmall,
            ),
            AppSpacing.h28,

            // ─── Profile Card ─────────────────────────────────────────────
            GestureDetector(
              onTap: () => _showEditProfile(context, settingsProvider),
              child: ProfileCard(
                name: settingsProvider.displayName,
                email: settingsProvider.email,
              ),
            ),
            AppSpacing.h28,

            // ─── Account Section ──────────────────────────────────────────
            SectionLabel(label: 'account'.tr),
            AppSpacing.h10,
            SettingsTile(
              icon: Icons.person_outline_rounded,
              label: 'editProfile'.tr,
              onTap: () => _showEditProfile(context, settingsProvider),
            ),
            SettingsTile(
              icon: Icons.lock_outline_rounded,
              label: 'changePassword'.tr,
              onTap: () => _showChangePassword(context, settingsProvider),
            ),

            AppSpacing.h24,

            // ─── Preferences Section ──────────────────────────────────────
            SectionLabel(label: 'preferences'.tr),
            AppSpacing.h10,
            ToggleTile(
              icon: Icons.notifications_outlined,
              label: 'notifications'.tr,
              value: settingsProvider.notificationsEnabled,
              onChanged: settingsProvider.toggleNotifications,
            ),
            ToggleTile(
              icon: Icons.save_outlined,
              label: 'autoSaveDrafts'.tr,
              value: settingsProvider.autoSaveEnabled,
              onChanged: settingsProvider.toggleAutoSave,
            ),
            SettingsTile(
              icon: Icons.language_rounded,
              label: 'language'.tr,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    settingsProvider.currentLanguage,
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
              onTap: () => _showLanguageDialog(context, settingsProvider),
            ),

            AppSpacing.h24,

            // ─── Info Section ─────────────────────────────────────────────
            SectionLabel(label: 'more'.tr),
            AppSpacing.h10,
            InfoTile(
              icon: Icons.edit_note_rounded,
              label: 'totalNotes'.tr,
              value: '${noteProvider.notes.length}',
            ),
            SettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'aboutReflections'.tr,
              onTap: () => _showAboutDialog(context),
            ),

            AppSpacing.h28,

            // ─── Logout ───────────────────────────────────────────────────
            LogoutButton(onTap: settingsProvider.logout),
            AppSpacing.h120, // Bottom padding to prevent floating bottom nav overlap
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              trailing: provider.currentLanguage == 'English'
                  ? const Icon(Icons.check, color: AppColors.primaryMedium)
                  : null,
              onTap: () {
                provider.changeLanguage('en');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('Español', style: AppFontManager.bodyMedium),
              trailing: provider.currentLanguage == 'Español'
                  ? const Icon(Icons.check, color: AppColors.primaryMedium)
                  : null,
              onTap: () {
                provider.changeLanguage('es');
                Navigator.of(context).pop();
              },
            ),
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
