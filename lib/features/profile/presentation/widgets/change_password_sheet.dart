import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/core/widgets/custom_button.dart';
import 'package:Reflections/core/providers/settings_provider.dart';

class ChangePasswordSheet extends StatefulWidget {
  final SettingsProvider provider;

  const ChangePasswordSheet({super.key, required this.provider});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onChange() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });
      final success = await widget.provider.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        if (success) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20.h,
        left: 24.w,
        right: 24.w,
        bottom: 24.h + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar for drag
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              Text(
                'Change Password',
                style: AppFontManager.headlineLarge,
              ),
              AppSpacing.h4,
              Text(
                'Protect your account with a secure password.',
                style: AppFontManager.bodySmall,
              ),
              AppSpacing.h24,

              // Current Password
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                style: AppFontManager.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Current password required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Current Password',
                  prefixIcon: Icon(
                    Icons.lock_open_rounded,
                    color: AppColors.textHint,
                    size: 20.sp,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textHint,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrent = !_obscureCurrent;
                      });
                    },
                  ),
                ),
              ),
              AppSpacing.h16,

              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                style: AppFontManager.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'New password required';
                  }
                  if (val.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'New Password',
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.textHint,
                    size: 20.sp,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textHint,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNew = !_obscureNew;
                      });
                    },
                  ),
                ),
              ),
              AppSpacing.h16,

              // Confirm New Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                style: AppFontManager.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Confirm your new password';
                  }
                  if (val != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Confirm New Password',
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.textHint,
                    size: 20.sp,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textHint,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                ),
              ),
              AppSpacing.h28,

              AppPrimaryButton(
                label: 'Change Password',
                isLoading: _isSaving,
                onPressed: _onChange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
