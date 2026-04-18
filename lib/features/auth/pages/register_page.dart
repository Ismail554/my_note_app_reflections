import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_notes/core/constants/app_constants.dart';
import 'package:my_notes/core/constants/app_strings.dart';
import 'package:my_notes/core/theme/app_colors.dart';
import 'package:my_notes/core/theme/app_font_manager.dart';
import 'package:my_notes/core/utils/app_validation.dart';
import 'package:my_notes/core/widgets/custom_button.dart';
import 'package:my_notes/features/auth/presentation/controllers/register_controller.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final RegisterController _controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.h52,

                // ─── Header ────────────────────────────────────────────
                Text(
                  AppStrings.registerTitle,
                  style: AppFontManager.displayMedium.copyWith(fontSize: 52.sp),
                ),
                AppSpacing.h8,
                Text(AppStrings.registerQuote, style: AppFontManager.subtitle),
                AppSpacing.h40,

                // ─── Name Field ────────────────────────────────────────
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: AppFontManager.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: AppValidation.name,
                  decoration: InputDecoration(
                    hintText: AppStrings.registerNameHint,
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.textHint,
                      size: 20.r,
                    ),
                  ),
                ),
                AppSpacing.h14,

                // ─── Email Field ───────────────────────────────────────
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppFontManager.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: AppValidation.email,
                  decoration: InputDecoration(
                    hintText: AppStrings.registerEmailHint,
                    prefixIcon: Icon(
                      Icons.mail_outline_rounded,
                      color: AppColors.textHint,
                      size: 20.r,
                    ),
                  ),
                ),
                AppSpacing.h14,

                // ─── Password Field ────────────────────────────────────
                Obx(
                  () => TextFormField(
                    textInputAction: TextInputAction.done,
                    controller: _passwordController,
                    obscureText: _controller.obscurePassword.value,
                    style: AppFontManager.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    validator: AppValidation.password,
                    decoration: InputDecoration(
                      hintText: AppStrings.registerPasswordHint,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.textHint,
                        size: 20.r,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: _controller.togglePasswordVisibility,
                        child: Icon(
                          _controller.obscurePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textHint,
                          size: 20.r,
                        ),
                      ),
                    ),
                  ),
                ),
                AppSpacing.h32,

                // ─── Error Message ─────────────────────────────────────
                Obx(() {
                  if (_controller.errorMessage.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        _controller.errorMessage.value,
                        style: AppFontManager.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  );
                }),

                // ─── Register Button ───────────────────────────────────
                Obx(
                  () => AppPrimaryButton(
                    label: AppStrings.registerButton,
                    isLoading: _controller.isLoading.value,
                    onPressed: _onRegister,
                  ),
                ),
                AppSpacing.h28,

                // ─── Footer ────────────────────────────────────────────
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: AppFontManager.bodySmall,
                      children: [
                        TextSpan(text: AppStrings.registerHaveAccount),
                        TextSpan(
                          text: AppStrings.registerReturnLogin,
                          style: AppFontManager.link.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _controller.navigateToLogin,
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.h32,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }
}
