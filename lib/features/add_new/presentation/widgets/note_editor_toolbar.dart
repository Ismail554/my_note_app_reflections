import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/localization/app_translations.dart';
import 'package:Reflections/features/add_new/presentation/widgets/toolbar_button.dart';

class NoteEditorToolbar extends StatelessWidget {
  final bool isPreviewMode;
  final bool isAutoSaving;
  final String bodyText;
  final String? currentNoteId;
  final bool hasCustomColor;
  final bool isDark;
  final bool customIsDark;
  final Color bodyColor;
  final Color secondaryTextColor;
  
  final VoidCallback onShowColorPicker;
  final VoidCallback onShowAiAssistant;
  final void Function(String prefix, String suffix) onInsertMarkdown;
  final VoidCallback onShowHighlightColorPicker;
  final VoidCallback onShowTextColorPicker;

  const NoteEditorToolbar({
    super.key,
    required this.isPreviewMode,
    required this.isAutoSaving,
    required this.bodyText,
    required this.currentNoteId,
    required this.hasCustomColor,
    required this.isDark,
    required this.customIsDark,
    required this.bodyColor,
    required this.secondaryTextColor,
    required this.onShowColorPicker,
    required this.onShowAiAssistant,
    required this.onInsertMarkdown,
    required this.onShowHighlightColorPicker,
    required this.onShowTextColorPicker,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: hasCustomColor
            ? (customIsDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03))
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        border: Border(
          top: BorderSide(
            color: hasCustomColor
                ? (customIsDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08))
                : AppColors.divider.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: isPreviewMode
            ? [
                const Spacer(),
                Builder(
                  builder: (context) {
                    final text = bodyText.trim();
                    final words = text.isEmpty
                        ? 0
                        : text.split(RegExp(r'\s+')).length;
                    final readTime = (words / 200).ceil();
                    final saveStatus = isAutoSaving
                        ? ' • ${'saving'.tr}'
                        : (currentNoteId != null && currentNoteId!.isNotEmpty
                            ? ' • ${'saved'.tr}'
                            : '');

                    return Text(
                      '$words ${'wordCount'.tr} • $readTime ${'readTime'.tr}$saveStatus',
                      style: AppFontManager.bodySmall.copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: secondaryTextColor,
                      ),
                    );
                  },
                ),
                const Spacer(),
              ]
            : [
                // Color picker launcher
                IconButton(
                  icon: Icon(
                    Icons.palette_outlined,
                    color: hasCustomColor
                        ? bodyColor
                        : AppColors.primaryGreen,
                    size: 20.sp,
                  ),
                  onPressed: onShowColorPicker,
                ),

                // Sparkles AI Assistant button
                IconButton(
                  icon: Icon(
                    Icons.auto_awesome_rounded,
                    color: const Color(0xFF8B5CF6), // Purple AI glow
                    size: 20.sp,
                  ),
                  tooltip: 'Gemini AI Assistant',
                  onPressed: onShowAiAssistant,
                ),

                Container(
                  height: 20.h,
                  width: 1.w,
                  color: hasCustomColor
                      ? (customIsDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08))
                      : AppColors.divider,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                ),

                // Formatting helpers inside a horizontal scroll view to fix overflow
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ToolbarButton(
                          icon: Icons.format_bold_rounded,
                          color: bodyColor,
                          onPressed: () => onInsertMarkdown('**', '**'),
                        ),
                        ToolbarButton(
                          icon: Icons.format_italic_rounded,
                          color: bodyColor,
                          onPressed: () => onInsertMarkdown('*', '*'),
                        ),
                        ToolbarButton(
                          icon: Icons.format_underlined_rounded,
                          color: bodyColor,
                          onPressed: () => onInsertMarkdown('<u>', '</u>'),
                        ),
                        ToolbarButton(
                          icon: Icons.border_color_rounded,
                          color: bodyColor,
                          onPressed: onShowHighlightColorPicker,
                        ),
                        ToolbarButton(
                          icon: Icons.format_color_text_rounded,
                          color: bodyColor,
                          onPressed: onShowTextColorPicker,
                        ),
                        ToolbarButton(
                          icon: Icons.title_rounded,
                          color: bodyColor,
                          onPressed: () => onInsertMarkdown('# ', ''),
                        ),
                        ToolbarButton(
                          icon: Icons.format_list_bulleted_rounded,
                          color: bodyColor,
                          onPressed: () => onInsertMarkdown('- ', ''),
                        ),
                        ToolbarButton(
                          icon: Icons.format_list_numbered_rounded,
                          color: bodyColor,
                          onPressed: () => onInsertMarkdown('1. ', ''),
                        ),
                        ToolbarButton(
                          icon: Icons.checklist_rounded,
                          color: bodyColor,
                          onPressed: () => onInsertMarkdown('- [ ] ', ''),
                        ),
                      ],
                    ),
                  ),
                ),

                // Statistics (Compact)
                Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: Builder(
                    builder: (context) {
                      final text = bodyText.trim();
                      final words = text.isEmpty
                          ? 0
                          : text.split(RegExp(r'\s+')).length;
                      final saveStatus = isAutoSaving
                          ? 'saving'.tr
                          : (currentNoteId != null && currentNoteId!.isNotEmpty
                              ? 'saved'.tr
                              : '');

                      return Text(
                        saveStatus.isNotEmpty
                            ? '$words w • $saveStatus'
                            : '$words w',
                        style: AppFontManager.bodySmall.copyWith(
                          fontSize: 10.sp,
                          color: isAutoSaving
                              ? const Color(0xFF8B5CF6)
                              : secondaryTextColor.withValues(alpha: 0.85),
                        ),
                      );
                    },
                  ),
                ),
              ],
      ),
    );
  }
}
