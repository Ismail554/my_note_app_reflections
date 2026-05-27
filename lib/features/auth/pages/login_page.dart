import 'package:Reflections/core/constants/app_assets.dart';
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
import 'package:Reflections/core/providers/login_provider.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginProvider>();

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
                        width: 64.w,
                        height: 64.h,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(IconAssets.appIcon),
                      ),
                      AppSpacing.h14,
                      Text(AppStrings.appName, style: AppFontManager.appTitle),
                    ],
                  ),
                ),
                AppSpacing.h48,
                // ─── Card ──────────────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(24.w),
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
                            size: 20.sp,
                          ),
                        ),
                      ),
                      AppSpacing.h16,
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: provider.obscurePassword,
                        style: AppFontManager.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        validator: AppValidation.password,
                        decoration: InputDecoration(
                          hintText: AppStrings.loginPasswordHint,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.textHint,
                            size: 20.sp,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: provider.togglePasswordVisibility,
                                child: Icon(
                                  provider.obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textHint,
                                  size: 20.sp,
                                ),
                              ),
                              AppSpacing.w14,
                            ],
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
                      if (provider.errorMessage.isNotEmpty) ...[
                        Padding(
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
                              provider.errorMessage,
                              style: AppFontManager.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                      // Login Button
                      AppPrimaryButton(
                        label: AppStrings.loginButton,
                        isLoading: provider.isLoading,
                        onPressed: () => _onLogin(context, provider),
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
                            ..onTap = provider.navigateToRegister,
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

  void _onLogin(BuildContext context, LoginProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      provider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }
}
