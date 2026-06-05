import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/core/services/gemini_service.dart';

class AiAssistantPanel extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final VoidCallback onUpdate;

  const AiAssistantPanel({
    super.key,
    required this.titleController,
    required this.bodyController,
    required this.onUpdate,
  });

  @override
  State<AiAssistantPanel> createState() => _AiAssistantPanelState();
}

class _AiAssistantPanelState extends State<AiAssistantPanel> {
  bool _isLoading = false;
  String _aiResult = '';
  String _selectedAction = '';

  Future<void> _triggerAction(String action) async {
    setState(() {
      _isLoading = true;
      _aiResult = '';
      _selectedAction = action;
    });

    String result = '';
    if (action == 'improve') {
      result = await GeminiService.instance.improveText(
        widget.bodyController.text,
      );
    } else if (action == 'title') {
      result = await GeminiService.instance.suggestTitle(
        widget.titleController.text,
        widget.bodyController.text,
      );
    } else if (action == 'pronounce') {
      result = await GeminiService.instance.fixMispronunciations(
        widget.bodyController.text,
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _aiResult = result;
      });
    }
  }

  void _applyChanges() {
    if (_aiResult.isEmpty) return;
    if (_selectedAction == 'title') {
      widget.titleController.text = _aiResult;
    } else {
      widget.bodyController.text = _aiResult;
    }
    widget.onUpdate();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final dividerColor = isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;
    final containerBg = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: 20.h,
          left: 24.w,
          right: 24.w,
          bottom: 32.h + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: panelBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: dividerColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: const Color(0xFF8B5CF6),
                    size: 24.sp,
                  ),
                  AppSpacing.w8,
                  Text(
                    'AI Note Assistant',
                    style: AppFontManager.headlineLarge.copyWith(
                      fontSize: 20.sp,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              AppSpacing.h4,
              Text(
                'Refine spelling, fix verbal slips, or generate ideas with AI.',
                style: AppFontManager.bodySmall.copyWith(color: textSecondary),
              ),
              AppSpacing.h20,

              if (_aiResult.isEmpty && !_isLoading) ...[
                Row(
                  children: [
                    Expanded(
                      child: AiCard(
                        icon: Icons.auto_fix_high_rounded,
                        label: 'Polish Note',
                        subLabel: 'Grammar & Flow',
                        onTap: () => _triggerAction('improve'),
                      ),
                    ),
                    AppSpacing.w12,
                    Expanded(
                      child: AiCard(
                        icon: Icons.title_rounded,
                        label: 'Suggest Title',
                        subLabel: 'Auto-generate title',
                        onTap: () => _triggerAction('title'),
                      ),
                    ),
                  ],
                ),
                AppSpacing.h12,
                AiCard(
                  icon: Icons.record_voice_over_rounded,
                  label: 'Fix Voice Transcription Mistakes',
                  subLabel: 'Fix phonetic misspellings & mispronunciations',
                  onTap: () => _triggerAction('pronounce'),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: containerBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: dividerColor),
                  ),
                  child: _isLoading
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppSpacing.h24,
                            const CircularProgressIndicator(
                              color: Color(0xFF8B5CF6),
                            ),
                            AppSpacing.h16,
                            Text(
                              'Gemini is working its magic...',
                              style: AppFontManager.bodyMedium.copyWith(
                                fontStyle: FontStyle.italic,
                                color: textSecondary,
                              ),
                            ),
                            AppSpacing.h24,
                          ],
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            _aiResult,
                            style: AppFontManager.bodyMedium.copyWith(
                              color: textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                ),
                AppSpacing.h20,
                if (!_isLoading)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _aiResult = '';
                              _selectedAction = '';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text('Retry', style: AppFontManager.buttonSmall),
                        ),
                      ),
                      AppSpacing.w12,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Apply to Note',
                            style: AppFontManager.buttonSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final VoidCallback onTap;

  const AiCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primarySurface.withValues(alpha: 0.1)
              : AppColors.primarySurface.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark
                ? AppColors.primarySurface.withValues(alpha: 0.3)
                : AppColors.primarySurface,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20.sp),
            ),
            AppSpacing.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppFontManager.headlineMedium.copyWith(
                      fontSize: 14.sp,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  AppSpacing.h2,
                  Text(
                    subLabel,
                    style: AppFontManager.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
