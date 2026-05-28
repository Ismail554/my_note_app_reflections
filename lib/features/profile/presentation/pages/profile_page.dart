import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/providers/settings_provider.dart';
import 'package:Reflections/core/services/data_export_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:Reflections/core/services/data_import_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();

    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          SizedBox(height: 16.h),
          // ─── Header ──────────────────────────────────────────
          Text(
            'Settings',
            style: AppFontManager.displayMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 24.h),

          // ─── Profile Section ─────────────────────────────────
          _SectionTitle(title: 'ACCOUNT', isDark: isDark),
          SizedBox(height: 8.h),
          _SettingsCard(
            isDark: isDark,
            children: [
              _ProfileRow(settings: settings, isDark: isDark),
              _Divider(isDark: isDark),
              _SettingsRow(
                icon: Icons.edit_rounded,
                label: 'Edit Name',
                isDark: isDark,
                onTap: () => _showEditNameDialog(context, settings, isDark),
              ),
              _Divider(isDark: isDark),
              _SettingsRow(
                icon: Icons.lock_rounded,
                label: 'Change Password',
                isDark: isDark,
                onTap: () => _showChangePasswordDialog(context, settings, isDark),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // ─── Appearance ──────────────────────────────────────
          _SectionTitle(title: 'APPEARANCE', isDark: isDark),
          SizedBox(height: 8.h),
          _SettingsCard(
            isDark: isDark,
            children: [
              _ToggleRow(
                icon: Icons.dark_mode_rounded,
                label: 'Dark Mode',
                value: settings.isDark,
                isDark: isDark,
                onChanged: (_) => settings.toggleTheme(),
              ),
              _Divider(isDark: isDark),
              _SettingsRow(
                icon: Icons.language_rounded,
                label: 'Language',
                trailing: settings.currentLanguage,
                isDark: isDark,
                onTap: () => _showLanguagePicker(context, settings, isDark),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // ─── Preferences ─────────────────────────────────────
          _SectionTitle(title: 'PREFERENCES', isDark: isDark),
          SizedBox(height: 8.h),
          _SettingsCard(
            isDark: isDark,
            children: [
              _ToggleRow(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                value: settings.notificationsEnabled,
                isDark: isDark,
                onChanged: settings.toggleNotifications,
              ),
              _Divider(isDark: isDark),
              _ToggleRow(
                icon: Icons.save_rounded,
                label: 'Auto Save',
                value: settings.autoSaveEnabled,
                isDark: isDark,
                onChanged: settings.toggleAutoSave,
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // ─── Data ────────────────────────────────────────────
          _SectionTitle(title: 'DATA', isDark: isDark),
          SizedBox(height: 8.h),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SettingsRow(
                icon: Icons.upload_rounded,
                label: 'Export Data',
                isDark: isDark,
                onTap: () => _exportData(context),
              ),
              _Divider(isDark: isDark),
              _SettingsRow(
                icon: Icons.download_rounded,
                label: 'Import Data',
                isDark: isDark,
                onTap: () => _importData(context),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // ─── Account Actions ─────────────────────────────────
          _SettingsCard(
            isDark: isDark,
            children: [
              _SettingsRow(
                icon: Icons.logout_rounded,
                label: 'Log Out',
                isDark: isDark,
                isDestructive: true,
                onTap: () => _confirmLogout(context, settings),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ─── App Version ─────────────────────────────────────
          Center(
            child: Text(
              'Reflections v1.0.0',
              style: AppFontManager.caption.copyWith(
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              ),
            ),
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────

  void _showEditNameDialog(BuildContext context, SettingsProvider settings, bool isDark) {
    final controller = TextEditingController(text: settings.displayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Your name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await settings.updateProfileName(controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, SettingsProvider settings, bool isDark) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Current password')),
            SizedBox(height: 12.h),
            TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'New password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final ok = await settings.changePassword(oldCtrl.text, newCtrl.text);
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Password updated' : 'Failed to update')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsProvider settings, bool isDark) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: settings.currentLanguage == 'English' ? const Icon(Icons.check, color: AppColors.accent) : null,
              onTap: () { settings.changeLanguage('en'); Navigator.pop(ctx); },
            ),
            ListTile(
              title: const Text('Español'),
              trailing: settings.currentLanguage == 'Español' ? const Icon(Icons.check, color: AppColors.accent) : null,
              onTap: () { settings.changeLanguage('es'); Navigator.pop(ctx); },
            ),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context) async {
    final error = await DataExportService.exportData();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Data exported successfully!')),
      );
    }
  }

  void _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final error = await DataImportService.importData(path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? 'Data restored successfully! Please restart app.')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No backup file selected.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  void _confirmLogout(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              settings.logout();
            },
            child: Text('Log Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  REUSABLE SETTINGS COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppFontManager.statLabel.copyWith(
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0.5,
      indent: 48.w,
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final SettingsProvider settings;
  final bool isDark;
  const _ProfileRow({required this.settings, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.accent.withValues(alpha: 0.15),
            child: Text(
              settings.displayName.isNotEmpty ? settings.displayName[0].toUpperCase() : '?',
              style: AppFontManager.headingMedium.copyWith(color: AppColors.accent),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.displayName,
                  style: AppFontManager.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  settings.email,
                  style: AppFontManager.caption.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final bool isDark;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    required this.isDark,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: isDestructive ? AppColors.error : AppColors.accent),
            SizedBox(width: 12.w),
            Expanded(child: Text(label, style: AppFontManager.bodyMedium.copyWith(color: color))),
            if (trailing != null) ...[
              Text(trailing!, style: AppFontManager.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              )),
              SizedBox(width: 4.w),
            ],
            Icon(Icons.chevron_right_rounded, size: 18.sp,
              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.accent),
          SizedBox(width: 12.w),
          Expanded(child: Text(label, style: AppFontManager.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
