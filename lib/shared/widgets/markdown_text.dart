import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';

/// A pure-Dart lightweight Markdown parser and renderer.
/// Renders headers, lists, checklists, bold, italic, and underline beautifully.
class MarkdownText extends StatelessWidget {
  final String text;
  final Color textColor;

  const MarkdownText({
    super.key,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final lines = text.split('\n');
    final children = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // 1. Header 1: "# Header"
      if (line.startsWith('# ')) {
        children.add(
          Padding(
            padding: EdgeInsets.only(top: 14.h, bottom: 6.h),
            child: Text(
              line.substring(2),
              style: AppFontManager.headingLarge.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        );
        continue;
      }

      // 2. Header 2: "## Header"
      if (line.startsWith('## ')) {
        children.add(
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
            child: Text(
              line.substring(3),
              style: AppFontManager.headingMedium.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        );
        continue;
      }

      // 3. Checklist Item: "- [ ] " or "- [x] "
      if (line.startsWith('- [ ] ') || line.startsWith('- [x] ')) {
        final isChecked = line.startsWith('- [x] ');
        final content = line.substring(6);
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 3.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  color: isChecked ? AppColors.primaryGreen : textColor.withValues(alpha: 0.6),
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: RichText(
                    text: _parseInlineMarkdown(content, isChecked),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // 4. Bullet List: "- Item"
      if (line.startsWith('- ')) {
        final content = line.substring(2);
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 3.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.h, left: 4.w, right: 8.w),
                  child: Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: _parseInlineMarkdown(content, false),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // 5. Standard paragraph line
      children.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: RichText(
            text: _parseInlineMarkdown(line, false),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Parses inline markdown elements (**bold**, *italic*, <u>underline</u>) into inline text spans.
  TextSpan _parseInlineMarkdown(String rawText, bool strikethrough) {
    final spans = <TextSpan>[];

    // RegExp for **bold**, *italic*, <u>underline</u>
    // Match them in priority or parse token by token
    int index = 0;

    final defaultStyle = AppFontManager.bodyMedium.copyWith(
      color: textColor,
      height: 1.5,
      decoration: strikethrough ? TextDecoration.lineThrough : TextDecoration.none,
    );

    while (index < rawText.length) {
      // Look for Bold "**"
      if (index < rawText.length - 1 && rawText.substring(index, index + 2) == '**') {
        final closingIndex = rawText.indexOf('**', index + 2);
        if (closingIndex != -1) {
          final boldText = rawText.substring(index + 2, closingIndex);
          spans.add(TextSpan(
            text: boldText,
            style: defaultStyle.copyWith(fontWeight: FontWeight.bold),
          ));
          index = closingIndex + 2;
          continue;
        }
      }

      // Look for Italic "*"
      if (rawText[index] == '*') {
        final closingIndex = rawText.indexOf('*', index + 1);
        if (closingIndex != -1) {
          final italicText = rawText.substring(index + 1, closingIndex);
          spans.add(TextSpan(
            text: italicText,
            style: defaultStyle.copyWith(fontStyle: FontStyle.italic),
          ));
          index = closingIndex + 1;
          continue;
        }
      }

      // Look for Underline "<u>" and "</u>"
      if (index < rawText.length - 2 && rawText.substring(index, index + 3) == '<u>') {
        final closingIndex = rawText.indexOf('</u>', index + 3);
        if (closingIndex != -1) {
          final underlinedText = rawText.substring(index + 3, closingIndex);
          spans.add(TextSpan(
            text: underlinedText,
            style: defaultStyle.copyWith(decoration: TextDecoration.underline),
          ));
          index = closingIndex + 4;
          continue;
        }
      }

      // Plain char
      spans.add(TextSpan(
        text: rawText[index],
        style: defaultStyle,
      ));
      index++;
    }

    return TextSpan(children: spans);
  }
}
