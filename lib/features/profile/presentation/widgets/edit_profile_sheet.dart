import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/core/widgets/custom_button.dart';
import 'package:Reflections/features/profile/presentation/controller/settings_controller.dart';

class EditProfileSheet extends StatefulWidget {
  final SettingsController controller;

  const EditProfileSheet({super.key, required this.controller});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final RxBool _isSaving = false.obs;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.controller.displayName.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      _isSaving.value = true;
      final success = await widget.controller.updateProfileName(_nameController.text.trim());
      _isSaving.value = false;
      if (success) {
        Get.back();
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

            Obx(
              () => AppPrimaryButton(
                label: 'Save Changes',
                isLoading: _isSaving.value,
                onPressed: _onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
