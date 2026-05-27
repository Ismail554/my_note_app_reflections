import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/core/widgets/custom_button.dart';
import 'package:Reflections/core/providers/settings_provider.dart';

class EditProfileSheet extends StatefulWidget {
  final SettingsProvider provider;

  const EditProfileSheet({super.key, required this.provider});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });
      final success = await widget.provider.updateProfileName(_nameController.text.trim());
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
              'Edit Profile',
              style: AppFontManager.headlineLarge,
            ),
            AppSpacing.h4,
            Text(
              'Update your display name.',
              style: AppFontManager.bodySmall,
            ),
            AppSpacing.h24,

            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              style: AppFontManager.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Name cannot be empty';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter your name',
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.textHint,
                  size: 20.sp,
                ),
              ),
            ),
            AppSpacing.h28,

            AppPrimaryButton(
              label: 'Save Changes',
              isLoading: _isSaving,
              onPressed: _onSave,
            ),
          ],
        ),
      ),
    );
  }
}
