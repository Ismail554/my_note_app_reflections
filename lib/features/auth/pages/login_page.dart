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
import 'package:my_notes/features/auth/presentation/controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginController _controller = Get.put(LoginController());

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
                AppSpacing.h60,

                // ─── Logo + App Name ────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 64.r,
                        height: 64.r,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.primaryDark,
                          size: 28.r,
                        ),
                      ),
                      AppSpacing.h14,
                      Text(AppStrings.appName, style: AppFontManager.appTitle),
                    ],
                  ),
                ),
                AppSpacing.h48,

                // ─── Card ──────────────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withAlpha(15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.loginTitle,
                        style: AppFontManager.headlineLarge,
                      ),
                      AppSpacing.h4,
                      Text(
                        AppStrings.loginSubtitle,
                        style: AppFontManager.bodySmall,
                      ),
                      AppSpacing.h24,

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppFontManager.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        validator: AppValidation.email,
                        decoration: InputDecoration(
                          hintText: AppStrings.loginEmailHint,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: AppColors.textHint,
                            size: 20.r,
                          ),
                        ),
                      ),
                      AppSpacing.h16,

                      // Password field
                      Obx(
                        () => TextFormField(
                          controller: _passwordController,
                          obscureText: _controller.obscurePassword.value,
                          style: AppFontManager.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          validator: AppValidation.password,
                          decoration: InputDecoration(
                            hintText: AppStrings.loginPasswordHint,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.textHint,
                              size: 20.r,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: _controller.togglePasswordVisibility,
                                  child: Icon(
                                    _controller.obscurePassword.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textHint,
                                    size: 20.r,
                                  ),
                                ),

                                SizedBox(width: 14.w),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.h12,

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AppStrings.loginForgotPassword,
                            style: AppFontManager.labelMedium.copyWith(
                              color: AppColors.primaryMedium,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.h12,

                      // Error message
                      Obx(() {
                        if (_controller.errorMessage.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
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

                      // Login Button
                      Obx(
                        () => AppPrimaryButton(
                          label: AppStrings.loginButton,
                          isLoading: _controller.isLoading.value,
                          onPressed: _onLogin,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.h28,

                // ─── Register account ────────────────────────────────────────────
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: AppFontManager.bodySmall,
                      children: [
                        TextSpan(
                          text: AppStrings.loginNoAccount,
                          style: AppFontManager.link.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: AppStrings.loginCreateAccount,
                          style: AppFontManager.link.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _controller.navigateToRegister,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }
}
