import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/core/constants/app_strings.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/utils/app_validation.dart';
import 'package:Reflections/core/widgets/custom_button.dart';
import 'package:Reflections/core/providers/register_provider.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();

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
                      size: 20.sp,
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
                      size: 20.sp,
                    ),
                  ),
                ),
                AppSpacing.h14,

                // ─── Password Field ────────────────────────────────────
                TextFormField(
                  textInputAction: TextInputAction.done,
                  controller: _passwordController,
                  obscureText: provider.obscurePassword,
                  style: AppFontManager.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: AppValidation.password,
                  decoration: InputDecoration(
                    hintText: AppStrings.registerPasswordHint,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textHint,
                      size: 20.sp,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: provider.togglePasswordVisibility,
                      child: Icon(
                        provider.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
                AppSpacing.h32,

                // ─── Error Message ─────────────────────────────────────
                if (provider.errorMessage.isNotEmpty) ...[
                  Padding(
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
                        provider.errorMessage,
                        style: AppFontManager.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],

                // ─── Register Button ───────────────────────────────────
                AppPrimaryButton(
                  label: AppStrings.registerButton,
                  isLoading: provider.isLoading,
                  onPressed: () => _onRegister(provider),
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
                            ..onTap = provider.navigateToLogin,
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

  void _onRegister(RegisterProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      provider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }
}
