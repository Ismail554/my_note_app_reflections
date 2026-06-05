import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/core/services/gemini_service.dart';

// ─── Word-level diff types ──────────────────────────────────────────────
enum _DiffType { same, added, removed }

class _DiffWord {
  final String text;
  final _DiffType type;
  const _DiffWord(this.text, this.type);
}

/// Compute word-level diff using LCS (Longest Common Subsequence).
List<_DiffWord> _computeWordDiff(String original, String modified) {
  final oldWords = original.split(RegExp(r'\s+'));
  final newWords = modified.split(RegExp(r'\s+'));
  if (oldWords.length == 1 && oldWords[0].isEmpty) oldWords.clear();
  if (newWords.length == 1 && newWords[0].isEmpty) newWords.clear();

  final m = oldWords.length, n = newWords.length;
  // Build LCS table
  final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
  for (int i = 1; i <= m; i++) {
    for (int j = 1; j <= n; j++) {
      if (oldWords[i - 1] == newWords[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
      } else {
        dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
      }
    }
  }

  // Backtrack to build diff
  final result = <_DiffWord>[];
  int i = m, j = n;
  while (i > 0 || j > 0) {
    if (i > 0 && j > 0 && oldWords[i - 1] == newWords[j - 1]) {
      result.add(_DiffWord(oldWords[i - 1], _DiffType.same));
      i--;
      j--;
    } else if (j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j])) {
      result.add(_DiffWord(newWords[j - 1], _DiffType.added));
      j--;
    } else {
      result.add(_DiffWord(oldWords[i - 1], _DiffType.removed));
      i--;
    }
  }
  return result.reversed.toList();
}

// ─── Main Panel ─────────────────────────────────────────────────────────
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
  String _originalText = '';
  final _customController = TextEditingController();
  String? _customError;

  // Actions that modify body text (eligible for diff view)
  static const _bodyActions = {
    'improve', 'pronounce', 'bullets', 'expand', 'summarize', 'formal', 'custom'
  };

  bool get _showDiff =>
      _aiResult.isNotEmpty &&
      !_isLoading &&
      _bodyActions.contains(_selectedAction) &&
      _selectedAction != 'summarize' &&
      _selectedAction != 'bullets';

  Future<void> _triggerAction(String action) async {
    final body = widget.bodyController.text.trim();
    if (body.isEmpty && action != 'title') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Write some note content first.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.r),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _aiResult = '';
      _selectedAction = action;
      _originalText = widget.bodyController.text;
    });

    String result = '';
    switch (action) {
      case 'improve':
        result = await GeminiService.instance.improveText(body);
        break;
      case 'title':
        result = await GeminiService.instance.suggestTitle(
          widget.titleController.text, body,
        );
        break;
      case 'pronounce':
        result = await GeminiService.instance.fixMispronunciations(body);
        break;
      case 'bullets':
        result = await GeminiService.instance.organizeBulletPoints(body);
        break;
      case 'expand':
        result = await GeminiService.instance.expandDetails(body);
        break;
      case 'summarize':
        result = await GeminiService.instance.summarize(body);
        break;
      case 'formal':
        result = await GeminiService.instance.makeFormal(body);
        break;
      case 'custom':
        result = await GeminiService.instance.customPrompt(
          body, _customController.text.trim(),
        );
        break;
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
    HapticFeedback.mediumImpact();
    if (_selectedAction == 'title') {
      widget.titleController.text = _aiResult;
    } else {
      widget.bodyController.text = _aiResult;
    }
    widget.onUpdate();
    Navigator.of(context).pop();
  }

  void _resetState() {
    setState(() {
      _aiResult = '';
      _selectedAction = '';
      _originalText = '';
      _customError = null;
    });
  }

  bool _validateCustomPrompt() {
    final text = _customController.text.trim();
    if (text.isEmpty) {
      setState(() => _customError = 'Please enter an instruction.');
      return false;
    }
    if (text.length < 5) {
      setState(() => _customError = 'Instruction too short (min 5 characters).');
      return false;
    }
    if (text.length > 500) {
      setState(() => _customError = 'Instruction too long (max 500 characters).');
      return false;
    }
    setState(() => _customError = null);
    return true;
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final containerBg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: 20.h, left: 24.w, right: 24.w,
          bottom: 32.h + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: panelBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
              blurRadius: 30, offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ──
              Center(
                child: Container(
                  width: 40.w, height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: dividerColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // ── Header ──
              Row(children: [
                Icon(Icons.auto_awesome_rounded,
                    color: const Color(0xFF8B5CF6), size: 24.sp),
                AppSpacing.w8,
                Text('AI Note Assistant',
                  style: AppFontManager.headlineLarge.copyWith(
                    fontSize: 20.sp, color: textPrimary,
                  ),
                ),
              ]),
              AppSpacing.h4,
              Text('Refine, restructure, or transform your note with AI.',
                style: AppFontManager.bodySmall.copyWith(color: textSecondary),
              ),
              AppSpacing.h20,

              // ── Command selection OR result view ──
              if (_aiResult.isEmpty && !_isLoading) ...[
                _buildCommandGrid(),
                AppSpacing.h16,
                _buildCustomPromptField(isDark, textPrimary, textSecondary, dividerColor, containerBg),
              ] else ...[
                _buildResultView(isDark, textPrimary, textSecondary, dividerColor, containerBg),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Command Grid ─────────────────────────────────────────────────────
  Widget _buildCommandGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Expanded(child: AiCard(
            icon: Icons.auto_fix_high_rounded,
            label: 'Polish Note', subLabel: 'Grammar & Flow',
            onTap: () => _triggerAction('improve'),
          )),
          AppSpacing.w12,
          Expanded(child: AiCard(
            icon: Icons.title_rounded,
            label: 'Suggest Title', subLabel: 'Auto-generate title',
            onTap: () => _triggerAction('title'),
          )),
        ]),
        AppSpacing.h12,
        Row(children: [
          Expanded(child: AiCard(
            icon: Icons.format_list_bulleted_rounded,
            label: 'Bullet Points', subLabel: 'Organize as list',
            onTap: () => _triggerAction('bullets'),
          )),
          AppSpacing.w12,
          Expanded(child: AiCard(
            icon: Icons.expand_rounded,
            label: 'Expand Details', subLabel: 'Add more depth',
            onTap: () => _triggerAction('expand'),
          )),
        ]),
        AppSpacing.h12,
        Row(children: [
          Expanded(child: AiCard(
            icon: Icons.compress_rounded,
            label: 'Summarize', subLabel: 'Key takeaways',
            onTap: () => _triggerAction('summarize'),
          )),
          AppSpacing.w12,
          Expanded(child: AiCard(
            icon: Icons.business_center_rounded,
            label: 'Make Formal', subLabel: 'Professional tone',
            onTap: () => _triggerAction('formal'),
          )),
        ]),
        AppSpacing.h12,
        AiCard(
          icon: Icons.record_voice_over_rounded,
          label: 'Fix Voice Transcription',
          subLabel: 'Fix phonetic misspellings & mispronunciations',
          onTap: () => _triggerAction('pronounce'),
        ),
      ],
    );
  }

  // ─── Custom Prompt Field ──────────────────────────────────────────────
  Widget _buildCustomPromptField(
    bool isDark, Color textPrimary, Color textSecondary,
    Color dividerColor, Color containerBg,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: dividerColor, height: 1),
        AppSpacing.h16,
        Text('Custom Instruction',
          style: AppFontManager.headlineMedium.copyWith(
            fontSize: 14.sp, color: textPrimary,
          ),
        ),
        AppSpacing.h8,
        Container(
          decoration: BoxDecoration(
            color: containerBg,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: _customError != null
                  ? AppColors.error.withValues(alpha: 0.6)
                  : dividerColor,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customController,
                  maxLines: 2,
                  minLines: 1,
                  maxLength: 500,
                  style: AppFontManager.bodyMedium.copyWith(
                    color: textPrimary, height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask AI anything about your note...',
                    hintStyle: AppFontManager.bodyMedium.copyWith(
                      color: textSecondary.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 12.h,
                    ),
                    counterText: '',
                  ),
                  onChanged: (_) {
                    if (_customError != null) setState(() => _customError = null);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: IconButton(
                  onPressed: () {
                    if (_validateCustomPrompt()) {
                      FocusScope.of(context).unfocus();
                      _triggerAction('custom');
                    }
                  },
                  icon: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5CF6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send_rounded,
                        color: Colors.white, size: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_customError != null) ...[
          AppSpacing.h4,
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Text(_customError!,
              style: AppFontManager.caption.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Result View ──────────────────────────────────────────────────────
  Widget _buildResultView(
    bool isDark, Color textPrimary, Color textSecondary,
    Color dividerColor, Color containerBg,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action label chip
        if (!_isLoading)
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _actionLabel(_selectedAction),
              style: AppFontManager.caption.copyWith(
                color: const Color(0xFF8B5CF6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // Result container
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.38,
          ),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: containerBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: dividerColor),
          ),
          child: _isLoading
              ? _buildLoadingState(textSecondary)
              : _showDiff
                  ? _buildDiffView(textPrimary)
                  : _buildPlainResult(textPrimary),
        ),
        AppSpacing.h20,

        // Action buttons
        if (!_isLoading)
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetState,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text('Back', style: AppFontManager.buttonSmall),
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
                  _selectedAction == 'title' ? 'Use Title' : 'Accept All',
                  style: AppFontManager.buttonSmall.copyWith(color: Colors.white),
                ),
              ),
            ),
          ]),
      ],
    );
  }

  Widget _buildLoadingState(Color textSecondary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSpacing.h24,
        const CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        AppSpacing.h16,
        Text('Gemini is working its magic...',
          style: AppFontManager.bodyMedium.copyWith(
            fontStyle: FontStyle.italic, color: textSecondary,
          ),
        ),
        AppSpacing.h24,
      ],
    );
  }

  Widget _buildPlainResult(Color textPrimary) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Text(_aiResult,
        style: AppFontManager.bodyMedium.copyWith(
          color: textPrimary, height: 1.5,
        ),
      ),
    );
  }

  Widget _buildDiffView(Color textPrimary) {
    final diffs = _computeWordDiff(_originalText, _aiResult);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: RichText(
        text: TextSpan(
          style: AppFontManager.bodyMedium.copyWith(
            color: textPrimary, height: 1.6,
          ),
          children: diffs.map((d) {
            switch (d.type) {
              case _DiffType.removed:
                return TextSpan(
                  text: '${d.text} ',
                  style: TextStyle(
                    color: AppColors.error.withValues(alpha: 0.8),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.error,
                  ),
                );
              case _DiffType.added:
                return TextSpan(
                  text: '${d.text} ',
                  style: TextStyle(
                    color: AppColors.success,
                    backgroundColor: AppColors.success.withValues(alpha: 0.12),
                    fontWeight: FontWeight.w500,
                  ),
                );
              case _DiffType.same:
                return TextSpan(text: '${d.text} ');
            }
          }).toList(),
        ),
      ),
    );
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'improve': return '✏️ Polish Note';
      case 'title': return '📝 Suggest Title';
      case 'pronounce': return '🎤 Fix Voice';
      case 'bullets': return '📋 Bullet Points';
      case 'expand': return '📖 Expand Details';
      case 'summarize': return '📄 Summarize';
      case 'formal': return '🎩 Make Formal';
      case 'custom': return '💬 Custom';
      default: return 'AI Result';
    }
  }
}

// ─── Reusable AiCard ────────────────────────────────────────────────────
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
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
        child: Row(children: [
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
                Text(label,
                  style: AppFontManager.headlineMedium.copyWith(
                    fontSize: 14.sp,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                AppSpacing.h2,
                Text(subLabel,
                  style: AppFontManager.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
