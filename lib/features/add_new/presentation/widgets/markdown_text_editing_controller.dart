import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';

/// A specialized custom [TextEditingController] that dynamically renders inline
/// markdown (**bold**, *italic*, `<u>underline</u>`, `==highlight==`, headers, `<color=...>`, and `<mark=...>` highlights)
/// live in the text editor.
class MarkdownTextEditingController extends TextEditingController {
  final ValueGetter<Color> getTextColor;

  MarkdownTextEditingController({
    super.text,
    required this.getTextColor,
  });

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final textStyle = style ?? TextStyle(color: getTextColor());
    return _parseMarkdownToSpan(text, textStyle);
  }

  TextSpan _parseMarkdownToSpan(String rawText, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    int index = 0;
    final plainBuffer = StringBuffer();

    void flushPlain() {
      if (plainBuffer.isNotEmpty) {
        spans.add(TextSpan(text: plainBuffer.toString(), style: baseStyle));
        plainBuffer.clear();
      }
    }

    // A helper to style helper tags so they are completely invisible.
    TextStyle tagStyle(TextStyle base) => const TextStyle(
          color: Colors.transparent,
          fontSize: 0.01,
          letterSpacing: -2.0,
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
          decoration: TextDecoration.none,
          backgroundColor: Colors.transparent,
        );

    bool isDigit(String char) => '0123456789'.contains(char);

    while (index < rawText.length) {
      final isStartOfLine = index == 0 || rawText[index - 1] == '\n';
      final endOfLine = rawText.indexOf('\n', index);
      final searchLimit = endOfLine == -1 ? rawText.length : endOfLine;

      // A. Checklist Item: "- [ ] " or "- [x] "
      // Render "- [ ] " / "- [x] " as dim prefix, then content normally.
      // NO duplication — raw chars render as themselves.
      if (isStartOfLine &&
          (rawText.startsWith('- [ ] ', index) ||
           rawText.startsWith('- [x] ', index) ||
           rawText.startsWith('- [X] ', index))) {
        flushPlain();
        final isChecked = rawText.startsWith('- [x] ', index) || rawText.startsWith('- [X] ', index);
        // Render the raw prefix chars visibly (dim), keeping cursor 1:1 with raw text
        spans.add(TextSpan(
          text: rawText.substring(index, index + 6),
          style: baseStyle.copyWith(
            color: isChecked ? AppColors.primaryGreen.withValues(alpha: 0.6) : baseStyle.color?.withValues(alpha: 0.35),
            fontWeight: FontWeight.bold,
            fontSize: (baseStyle.fontSize ?? 16) * 0.85,
          ),
        ));
        index += 6;
        continue;
      }

      // B. Bullet Item: "- " or "* "
      // Render raw prefix chars as dim bullet marker — no ghost chars.
      if (isStartOfLine &&
          (rawText.startsWith('- ', index) || rawText.startsWith('* ', index))) {
        flushPlain();
        spans.add(TextSpan(
          text: rawText.substring(index, index + 2),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: baseStyle.color?.withValues(alpha: 0.5),
          ),
        ));
        index += 2;
        continue;
      }

      // C. Numbered Item: e.g. "1. " at the start of a line
      // Render raw "1. " as styled prefix — no duplication.
      if (isStartOfLine) {
        int searchIdx = index;
        while (searchIdx < rawText.length && isDigit(rawText[searchIdx])) {
          searchIdx++;
        }
        if (searchIdx > index && rawText.startsWith('. ', searchIdx)) {
          flushPlain();
          final numText = rawText.substring(index, searchIdx + 2);
          spans.add(TextSpan(
            text: numText,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: baseStyle.color?.withValues(alpha: 0.6),
            ),
          ));
          index = searchIdx + 2;
          continue;
        }
      }

      // D. Bold "**"
      if (rawText.startsWith('**', index)) {
        final closingIndex = rawText.indexOf('**', index + 2);
        if (closingIndex != -1 && closingIndex < searchLimit) {
          flushPlain();
          spans.add(TextSpan(text: '**', style: tagStyle(baseStyle)));
          final boldText = rawText.substring(index + 2, closingIndex);
          spans.add(TextSpan(
            text: boldText,
            style: baseStyle.copyWith(fontWeight: FontWeight.bold),
          ));
          spans.add(TextSpan(text: '**', style: tagStyle(baseStyle)));
          index = closingIndex + 2;
          continue;
        }
      }

      // E. Highlight "==" or "<mark>" / "<mark=color>"
      if (rawText.startsWith('==', index)) {
        final closingIndex = rawText.indexOf('==', index + 2);
        if (closingIndex != -1 && closingIndex < searchLimit) {
          flushPlain();
          spans.add(TextSpan(text: '==', style: tagStyle(baseStyle)));
          final highlightedText = rawText.substring(index + 2, closingIndex);
          spans.add(TextSpan(
            text: highlightedText,
            style: baseStyle.copyWith(
              backgroundColor: const Color(0xFFFFF9C4),
              color: Colors.black87,
            ),
          ));
          spans.add(TextSpan(text: '==', style: tagStyle(baseStyle)));
          index = closingIndex + 2;
          continue;
        }
      }

      if (rawText.startsWith('<mark', index)) {
        final closingIndex = rawText.indexOf('>', index + 5);
        if (closingIndex != -1 && closingIndex < searchLimit) {
          final markAttr = rawText.startsWith('<mark=', index)
              ? rawText.substring(index + 6, closingIndex)
              : 'yellow';
          final endTagIndex = rawText.indexOf('</mark>', closingIndex + 1);
          if (endTagIndex != -1 && endTagIndex < searchLimit) {
            flushPlain();
            final highlightedText = rawText.substring(closingIndex + 1, endTagIndex);
            
            Color parsedBg = const Color(0xFFFFF9C4); // default yellow
            try {
              if (markAttr.startsWith('#')) {
                final hexStr = markAttr.replaceAll('#', '');
                if (hexStr.length == 6) {
                  parsedBg = Color(int.parse('FF$hexStr', radix: 16));
                } else if (hexStr.length == 8) {
                  parsedBg = Color(int.parse(hexStr, radix: 16));
                }
              } else {
                switch (markAttr.toLowerCase()) {
                  case 'yellow':
                    parsedBg = const Color(0xFFFFF9C4);
                    break;
                  case 'green':
                    parsedBg = const Color(0xFFC8E6C9);
                    break;
                  case 'blue':
                    parsedBg = const Color(0xFFBBDEFB);
                    break;
                  case 'pink':
                    parsedBg = const Color(0xFFF8BBD0);
                    break;
                  case 'orange':
                    parsedBg = const Color(0xFFFFE0B2);
                    break;
                  case 'red':
                    parsedBg = const Color(0xFFFFCDD2);
                    break;
                  case 'purple':
                    parsedBg = const Color(0xFFE1BEE7);
                    break;
                  case 'teal':
                    parsedBg = const Color(0xFFB2DFDB);
                    break;
                }
              }
            } catch (_) {}

            spans.add(TextSpan(text: '<mark=$markAttr>', style: tagStyle(baseStyle)));
            spans.add(TextSpan(
              text: highlightedText,
              style: baseStyle.copyWith(
                backgroundColor: parsedBg,
                color: Colors.black87,
              ),
            ));
            spans.add(TextSpan(text: '</mark>', style: tagStyle(baseStyle)));
            index = endTagIndex + 7;
            continue;
          }
        }
      }

      // F. Underline "<u>"
      if (rawText.startsWith('<u>', index)) {
        final closingIndex = rawText.indexOf('</u>', index + 3);
        if (closingIndex != -1 && closingIndex < searchLimit) {
          flushPlain();
          spans.add(TextSpan(text: '<u>', style: tagStyle(baseStyle)));
          final underlinedText = rawText.substring(index + 3, closingIndex);
          spans.add(TextSpan(
            text: underlinedText,
            style: baseStyle.copyWith(decoration: TextDecoration.underline),
          ));
          spans.add(TextSpan(text: '</u>', style: tagStyle(baseStyle)));
          index = closingIndex + 4;
          continue;
        }
      }

      // G. Color "<color="
      if (rawText.startsWith('<color=', index)) {
        final closingIndex = rawText.indexOf('>', index + 7);
        if (closingIndex != -1 && closingIndex < searchLimit) {
          final colorAttr = rawText.substring(index + 7, closingIndex);
          final endTagIndex = rawText.indexOf('</color>', closingIndex + 1);
          if (endTagIndex != -1 && endTagIndex < searchLimit) {
            flushPlain();
            final coloredText = rawText.substring(closingIndex + 1, endTagIndex);
            
            Color parsedColor = baseStyle.color ?? Colors.black;
            try {
              if (colorAttr.startsWith('#')) {
                final hexStr = colorAttr.replaceAll('#', '');
                if (hexStr.length == 6) {
                  parsedColor = Color(int.parse('FF$hexStr', radix: 16));
                } else if (hexStr.length == 8) {
                  parsedColor = Color(int.parse(hexStr, radix: 16));
                }
              } else {
                switch (colorAttr.toLowerCase()) {
                  case 'red':
                    parsedColor = const Color(0xFFEF5350);
                    break;
                  case 'green':
                    parsedColor = const Color(0xFF66BB6A);
                    break;
                  case 'blue':
                    parsedColor = const Color(0xFF42A5F5);
                    break;
                  case 'orange':
                    parsedColor = const Color(0xFFFFA726);
                    break;
                  case 'purple':
                    parsedColor = const Color(0xFFAB47BC);
                    break;
                  case 'yellow':
                    parsedColor = const Color(0xFFFFEE58);
                    break;
                  case 'pink':
                    parsedColor = const Color(0xFFEC407A);
                    break;
                  case 'teal':
                    parsedColor = const Color(0xFF26A69A);
                    break;
                }
              }
            } catch (_) {}

            spans.add(TextSpan(text: '<color=$colorAttr>', style: tagStyle(baseStyle)));
            spans.add(TextSpan(
              text: coloredText,
              style: baseStyle.copyWith(color: parsedColor),
            ));
            spans.add(TextSpan(text: '</color>', style: tagStyle(baseStyle)));
            index = endTagIndex + 8;
            continue;
          }
        }
      }

      // H. Italic "*"
      if (rawText.startsWith('*', index)) {
        final closingIndex = rawText.indexOf('*', index + 1);
        if (closingIndex != -1 && closingIndex < searchLimit) {
          flushPlain();
          spans.add(TextSpan(text: '*', style: tagStyle(baseStyle)));
          final italicText = rawText.substring(index + 1, closingIndex);
          spans.add(TextSpan(
            text: italicText,
            style: baseStyle.copyWith(fontStyle: FontStyle.italic),
          ));
          spans.add(TextSpan(text: '*', style: tagStyle(baseStyle)));
          index = closingIndex + 1;
          continue;
        }
      }

      // I. Header "## " (must check before "# ")
      if (isStartOfLine && rawText.startsWith('## ', index)) {
        flushPlain();
        final endOfLine = rawText.indexOf('\n', index + 3);
        final lineLen = endOfLine == -1 ? rawText.length - (index + 3) : endOfLine - (index + 3);
        final headerText = rawText.substring(index + 3, index + 3 + lineLen);
        final headerFontSize = baseStyle.fontSize != null ? baseStyle.fontSize! * 1.15 : 17.sp;
        // Render "## " prefix visible but dim (cursor stays 1:1 with raw text)
        spans.add(TextSpan(
          text: '## ',
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: headerFontSize,
            color: baseStyle.color?.withValues(alpha: 0.35),
          ),
        ));
        spans.add(TextSpan(
          text: headerText,
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: headerFontSize,
          ),
        ));
        index = index + 3 + lineLen;
        continue;
      }

      if (isStartOfLine && rawText.startsWith('# ', index)) {
        flushPlain();
        final endOfLine = rawText.indexOf('\n', index + 2);
        final lineLen = endOfLine == -1 ? rawText.length - (index + 2) : endOfLine - (index + 2);
        final headerText = rawText.substring(index + 2, index + 2 + lineLen);
        final headerFontSize = baseStyle.fontSize != null ? baseStyle.fontSize! * 1.35 : 20.sp;
        // Render "# " prefix visible but dim (cursor stays 1:1 with raw text)
        spans.add(TextSpan(
          text: '# ',
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: headerFontSize,
            color: baseStyle.color?.withValues(alpha: 0.35),
          ),
        ));
        spans.add(TextSpan(
          text: headerText,
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: headerFontSize,
          ),
        ));
        index = index + 2 + lineLen;
        continue;
      }

      // Plain char
      plainBuffer.write(rawText[index]);
      index++;
    }

    flushPlain();
    return TextSpan(children: spans);
  }
}
