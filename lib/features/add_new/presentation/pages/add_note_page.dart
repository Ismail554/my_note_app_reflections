import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/widgets/note_save_button.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/shared/models/note_model.dart';
import 'package:Reflections/core/localization/app_translations.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/shared/widgets/markdown_text.dart';

// Modular Presentation Widgets & Controllers
import 'package:Reflections/features/add_new/presentation/widgets/meta_chip.dart';
import 'package:Reflections/features/add_new/presentation/widgets/ai_assistant_panel.dart';
import 'package:Reflections/features/add_new/presentation/widgets/version_history_sheet.dart';
import 'package:Reflections/features/add_new/presentation/widgets/markdown_text_editing_controller.dart';
import 'package:Reflections/features/add_new/presentation/widgets/note_color_picker_sheet.dart';
import 'package:Reflections/features/add_new/presentation/widgets/note_text_color_picker_sheet.dart';
import 'package:Reflections/features/add_new/presentation/widgets/note_highlight_color_picker_sheet.dart';
import 'package:Reflections/features/add_new/presentation/widgets/note_text_size_picker_sheet.dart';
import 'package:Reflections/features/add_new/presentation/widgets/note_editor_toolbar.dart';

class AddNotePage extends StatefulWidget {
  final NoteModel? note;
  const AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _titleController = TextEditingController();
  late final MarkdownTextEditingController _bodyController;
  final _bodyFocusNode = FocusNode();

  bool _isSaving = false;
  late String _categoryName;

  int _selectedColor = 0;
  bool _isPinned = false;
  bool _isPreviewMode = false;
  double _bodyFontSize = 16.0;

  Timer? _autoSaveTimer;
  String? _currentNoteId;
  String _lastSavedTitle = '';
  String _lastSavedBody = '';
  bool _isAutoSaving = false;
  bool _canPop = false;

  bool get _isDirty {
    final title = _titleController.text.trim();
    final body = _bodyController.text;
    final originalNote = widget.note;

    if (originalNote == null) {
      return title.isNotEmpty ||
          body.isNotEmpty ||
          _selectedColor != 0 ||
          _isPinned;
    }

    return title != originalNote.title ||
        body != originalNote.description ||
        _selectedColor != originalNote.colorValue ||
        _isPinned != originalNote.isPinned ||
        _categoryName != originalNote.category;
  }

  @override
  void initState() {
    _bodyController = MarkdownTextEditingController(
      getTextColor: () {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final hasCustomColor = _selectedColor != 0;
        final customIsDark = hasCustomColor
            ? ThemeData.estimateBrightnessForColor(Color(_selectedColor)) ==
                  Brightness.dark
            : isDark;
        return hasCustomColor
            ? (customIsDark
                  ? AppColors.white.withValues(alpha: 0.92)
                  : AppColors.lightTextPrimary.withValues(alpha: 0.92))
            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
      },
    );
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _bodyController.text = widget.note!.description;
      _categoryName = widget.note!.category;
      _selectedColor = widget.note!.colorValue;
      _isPinned = widget.note!.isPinned;
      _isPreviewMode = true;
    } else {
      _selectedColor = 0;
      _isPinned = false;
      final noteProvider = context.read<NoteProvider>();
      _categoryName = noteProvider.selectedFolder == 'All'
          ? 'Reflections'
          : noteProvider.selectedFolder;
    }
    _currentNoteId = widget.note?.id;
    _lastSavedTitle = _titleController.text;
    _lastSavedBody = _bodyController.text;

    _titleController.addListener(_onTextChanged);
    _bodyController.addListener(() {
      _onTextChanged();
      setState(() {});
    });
  }

  void _onTextChanged() {
    final title = _titleController.text.trim();
    final body = _bodyController.text;
    if (title == _lastSavedTitle && body == _lastSavedBody) return;

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () => _autoSave());
  }

  Future<void> _autoSave() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text;
    if (title.isEmpty || _isSaving) return;
    if (title == _lastSavedTitle && body == _lastSavedBody) return;

    if (!mounted) return;
    setState(() => _isAutoSaving = true);

    final isEditing = _currentNoteId != null && _currentNoteId!.isNotEmpty;
    final note = NoteModel(
      id: isEditing ? _currentNoteId! : '',
      title: title,
      description: body,
      createdAt: isEditing && widget.note != null
          ? widget.note!.createdAt
          : DateTime.now(),
      updatedAt: DateTime.now(),
      userId: isEditing && widget.note != null ? widget.note!.userId : '',
      category: _categoryName,
      isArchived: isEditing && widget.note != null
          ? widget.note!.isArchived
          : false,
      colorValue: _selectedColor,
      isPinned: _isPinned,
    );

    try {
      final noteProvider = context.read<NoteProvider>();
      if (isEditing) {
        await noteProvider.updateNote(note);
      } else {
        _currentNoteId = await noteProvider.addNote(note);
      }
      _lastSavedTitle = title;
      _lastSavedBody = body;
    } catch (e) {
      debugPrint('Auto-save error: $e');
    }

    if (mounted) setState(() => _isAutoSaving = false);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    // Dismiss keyboard first to restore full Scaffold height
    FocusManager.instance.primaryFocus?.unfocus();

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('errorEmpty'.tr),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.r),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    _autoSaveTimer?.cancel();
    setState(() => _isSaving = true);

    final isEditing =
        (_currentNoteId != null && _currentNoteId!.isNotEmpty) ||
        widget.note != null;
    final noteId = (_currentNoteId != null && _currentNoteId!.isNotEmpty)
        ? _currentNoteId!
        : (widget.note != null ? widget.note!.id : '');

    final note = NoteModel(
      id: noteId,
      title: title,
      description: _bodyController.text.trim(),
      createdAt: (widget.note != null)
          ? widget.note!.createdAt
          : DateTime.now(),
      updatedAt: DateTime.now(),
      userId: (widget.note != null) ? widget.note!.userId : '',
      category: _categoryName,
      isArchived: (widget.note != null) ? widget.note!.isArchived : false,
      colorValue: _selectedColor,
      isPinned: _isPinned,
    );

    final noteProvider = context.read<NoteProvider>();
    final navigator = Navigator.of(context);
    try {
      if (isEditing && noteId.isNotEmpty) {
        await noteProvider.updateNote(note);
      } else {
        await noteProvider.addNote(note);
      }
    } catch (e) {
      debugPrint('Save error: $e');
    }

    if (mounted) {
      setState(() => _isSaving = false);
      navigator.pop();
    }
  }

  Future<void> _archiveNote(BuildContext context) async {
    final noteId = (_currentNoteId != null && _currentNoteId!.isNotEmpty)
        ? _currentNoteId!
        : (widget.note != null ? widget.note!.id : '');
    if (noteId.isEmpty) return;

    final navigator = Navigator.of(context);
    await context.read<NoteProvider>().archiveNote(noteId, true);
    if (mounted) navigator.pop();
  }

  void _showVersionHistory() {
    final noteId = (_currentNoteId != null && _currentNoteId!.isNotEmpty)
        ? _currentNoteId!
        : (widget.note != null ? widget.note!.id : '');
    if (noteId.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => VersionHistorySheet(
        currentNoteId: noteId,
        onRestore: (title, desc) {
          Navigator.pop(context);
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            _titleController.text = title;
            _bodyController.text = desc;
            _isPreviewMode = false;
          });
          _autoSave();
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('restoreSuccess'.tr),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16.r),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        },
      ),
    );
  }

  void _insertMarkdown(
    String prefix,
    String suffix, {
    TextSelection? forceSelection,
  }) {
    final text = _bodyController.text;
    final selection = forceSelection ?? _bodyController.selection;
    int start = selection.start < 0 ? text.length : selection.start;
    int end = selection.end < 0 ? text.length : selection.end;

    // Line-level prefixes: must go at the start of the current line
    final isLinePrefix =
        suffix.isEmpty &&
        (prefix == '# ' ||
            prefix == '## ' ||
            prefix == '- ' ||
            prefix == '* ' ||
            prefix.startsWith('- [') ||
            RegExp(r'^\d+\. $').hasMatch(prefix));

    if (isLinePrefix) {
      // Find start of current line
      int lineStart = text.lastIndexOf('\n', start - 1);
      lineStart = lineStart == -1 ? 0 : lineStart + 1;

      final lineText = text.substring(lineStart);

      // Define a regex that matches any known line prefix
      final prefixRegex = RegExp(
        r'^(## |# |- |\* |- \[\s\] |- \[x\] |- \[X\] |\d+\. )',
      );
      final match = prefixRegex.firstMatch(lineText);

      if (match != null) {
        final existingPrefix = match.group(0)!;
        if (existingPrefix == prefix) {
          // Toggle off: remove the prefix
          _bodyController.text = text.replaceRange(
            lineStart,
            lineStart + existingPrefix.length,
            '',
          );
          _bodyController.selection = TextSelection.collapsed(
            offset: (start - existingPrefix.length).clamp(
              0,
              _bodyController.text.length,
            ),
          );
        } else {
          // Replace existing prefix with new prefix
          _bodyController.text = text.replaceRange(
            lineStart,
            lineStart + existingPrefix.length,
            prefix,
          );
          final diff = prefix.length - existingPrefix.length;
          _bodyController.selection = TextSelection.collapsed(
            offset: (start + diff).clamp(0, _bodyController.text.length),
          );
        }
      } else {
        // No prefix exists, insert new prefix
        _bodyController.text = text.replaceRange(lineStart, lineStart, prefix);
        _bodyController.selection = TextSelection.collapsed(
          offset: start + prefix.length,
        );
      }
    } else {
      // Wrap-style (bold, italic, underline, color, highlight, etc.)
      final selectedText = text.substring(start, end);
      final replacement = '$prefix$selectedText$suffix';
      _bodyController.text = text.replaceRange(start, end, replacement);
      _bodyController.selection = TextSelection.collapsed(
        offset: start + prefix.length + selectedText.length,
      );
    }

    setState(() {});
    _bodyFocusNode.requestFocus();
  }

  void _showColorPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => NoteColorPickerSheet(
        selectedColor: _selectedColor,
        onColorSelected: (val) {
          setState(() => _selectedColor = val);
          _autoSave();
        },
      ),
    ).whenComplete(() => _bodyFocusNode.requestFocus());
  }

  void _showTextColorPicker() {
    final selection = _bodyController.selection;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => NoteTextColorPickerSheet(
        onColorSelected: (hex) => _insertMarkdown(
          '<color=$hex>',
          '</color>',
          forceSelection: selection,
        ),
      ),
    ).whenComplete(() => _bodyFocusNode.requestFocus());
  }

  void _showHighlightColorPicker() {
    final selection = _bodyController.selection;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => NoteHighlightColorPickerSheet(
        onHighlightSelected: (hex) => _insertMarkdown(
          '<mark=$hex>',
          '</mark>',
          forceSelection: selection,
        ),
      ),
    ).whenComplete(() => _bodyFocusNode.requestFocus());
  }

  void _showTextSizePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => NoteTextSizePickerSheet(
        initialFontSize: _bodyFontSize,
        onFontSizeChanged: (val) => setState(() => _bodyFontSize = val),
      ),
    ).whenComplete(() => _bodyFocusNode.requestFocus());
  }

  void _showAiAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiAssistantPanel(
        titleController: _titleController,
        bodyController: _bodyController,
        onUpdate: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'MMMM d, y',
    ).format(widget.note != null ? widget.note!.createdAt : DateTime.now());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCustomColor = _selectedColor != 0;
    final canvasColor = hasCustomColor
        ? Color(_selectedColor)
        : (isDark ? AppColors.darkBackground : AppColors.lightBackground);
    final customIsDark = hasCustomColor
        ? ThemeData.estimateBrightnessForColor(Color(_selectedColor)) ==
              Brightness.dark
        : isDark;
    final titleColor = hasCustomColor
        ? (customIsDark ? AppColors.white : AppColors.lightTextPrimary)
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    final bodyColor = hasCustomColor
        ? (customIsDark
              ? AppColors.white.withValues(alpha: 0.92)
              : AppColors.lightTextPrimary.withValues(alpha: 0.92))
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    final secondaryTextColor = hasCustomColor
        ? (customIsDark
              ? AppColors.white.withValues(alpha: 0.76)
              : AppColors.lightTextSecondary)
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);
    final hintColor = hasCustomColor
        ? (customIsDark
              ? AppColors.white.withValues(alpha: 0.55)
              : AppColors.lightTextMuted.withValues(alpha: 0.75))
        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted);

    return Hero(
      tag: widget.note != null ? 'note_${widget.note!.id}' : 'new_note_hero',
      child: PopScope(
        canPop: _canPop,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _autoSaveTimer?.cancel();
          if (_isDirty) {
            await _autoSave();
          }
          if (context.mounted) {
            setState(() {
              _canPop = true;
            });
            Navigator.of(context).pop();
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: customIsDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: canvasColor,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
            child: Column(
              children: [
                // Top AppBar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: hasCustomColor
                                ? (customIsDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.06))
                                : (isDark
                                      ? AppColors.darkSurfaceVariant
                                      : AppColors.lightSurfaceVariant),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: bodyColor,
                            size: 18.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            widget.note != null
                                ? 'addNoteEdit'.tr
                                : 'addNoteTitle'.tr,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontManager.headlineMedium.copyWith(
                              color: titleColor,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.text_fields_rounded,
                          color: secondaryTextColor,
                          size: 20.sp,
                        ),
                        tooltip: 'textSizeScaling'.tr,
                        onPressed: _showTextSizePicker,
                      ),
                      IconButton(
                        icon: Icon(
                          _isPreviewMode
                              ? Icons.edit_outlined
                              : Icons.visibility_outlined,
                          color: secondaryTextColor,
                          size: 20.sp,
                        ),
                        tooltip: _isPreviewMode
                            ? 'addNoteEdit'.tr
                            : 'previewLabel'.tr,
                        onPressed: () =>
                            setState(() => _isPreviewMode = !_isPreviewMode),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: secondaryTextColor,
                          size: 20.sp,
                        ),
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        onSelected: (value) async {
                          if (value == 'pin') {
                            setState(() => _isPinned = !_isPinned);
                          } else if (value == 'history') {
                            _showVersionHistory();
                          } else if (value == 'delete') {
                            await _archiveNote(context);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'pin',
                            child: Row(
                              children: [
                                Icon(
                                  _isPinned
                                      ? Icons.push_pin_rounded
                                      : Icons.push_pin_outlined,
                                  color: _isPinned
                                      ? const Color(0xFFC6A052)
                                      : secondaryTextColor,
                                  size: 18.sp,
                                ),
                                AppSpacing.w10,
                                Text(
                                  _isPinned ? 'unpinNote'.tr : 'pinNote'.tr,
                                  style: AppFontManager.bodyMedium.copyWith(
                                    color: bodyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if ((_currentNoteId != null &&
                                  _currentNoteId!.isNotEmpty) ||
                              (widget.note != null &&
                                  widget.note!.id.isNotEmpty))
                            PopupMenuItem<String>(
                              value: 'history',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    color: secondaryTextColor,
                                    size: 18.sp,
                                  ),
                                  AppSpacing.w10,
                                  Text(
                                    'versionHistory'.tr,
                                    style: AppFontManager.bodyMedium.copyWith(
                                      color: bodyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.note != null ||
                              (_currentNoteId != null &&
                                  _currentNoteId!.isNotEmpty))
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.archive_outlined,
                                    color: AppColors.error,
                                    size: 18.sp,
                                  ),
                                  AppSpacing.w10,
                                  Text(
                                    'archiveNote'.tr,
                                    style: AppFontManager.bodyMedium.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      AppSaveButton(
                        isLoading: _isSaving,
                        onPressed: () => _save(context),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: hasCustomColor
                      ? (customIsDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.08))
                      : (isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider),
                ),

                // Metadata Row
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    children: [
                      MetaChip(
                        icon: Icons.calendar_today_outlined,
                        label: dateStr,
                        hasCustomColor: hasCustomColor,
                        isDark: customIsDark,
                      ),
                      AppSpacing.w10,
                      MetaChip(
                        icon: Icons.folder_outlined,
                        label: _categoryName,
                        hasCustomColor: hasCustomColor,
                        isDark: customIsDark,
                      ),
                    ],
                  ),
                ),

                // Editor Workspace
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (!_isPreviewMode && !_bodyFocusNode.hasFocus) {
                        _bodyFocusNode.requestFocus();
                        // Move cursor to the end of the text
                        _bodyController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _bodyController.text.length),
                        );
                      }
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isPreviewMode
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Text(
                                    _titleController.text.isEmpty
                                        ? 'untitled'.tr
                                        : _titleController.text,
                                    style: AppFontManager.inputTitle.copyWith(
                                      color: titleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : TextField(
                                  textInputAction: TextInputAction.next,
                                  controller: _titleController,
                                  cursorColor: titleColor,
                                  style: AppFontManager.inputTitle.copyWith(
                                    color: titleColor,
                                  ),
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    hintText: 'addNoteTitleHint'.tr,
                                    hintStyle: AppFontManager.inputTitle
                                        .copyWith(color: hintColor),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                  ),
                                ),
                          AppSpacing.h12,
                          Divider(
                            color: hasCustomColor
                                ? (customIsDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.black.withValues(alpha: 0.08))
                                : (isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightDivider),
                          ),
                          AppSpacing.h12,
                          _isPreviewMode
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: 40.h),
                                  child: _bodyController.text.trim().isEmpty
                                      ? Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 40.h,
                                            horizontal: 16.w,
                                          ),
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.edit_note_rounded,
                                                size: 40.sp,
                                                color: secondaryTextColor
                                                    .withValues(alpha: 0.45),
                                              ),
                                              SizedBox(height: 12.h),
                                              Text(
                                                'noContentText'.tr,
                                                textAlign: TextAlign.center,
                                                style: AppFontManager.bodyMedium
                                                    .copyWith(
                                                      color: secondaryTextColor
                                                          .withValues(
                                                            alpha: 0.82,
                                                          ),
                                                      height: 1.4,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : MarkdownText(
                                          text: _bodyController.text,
                                          textColor: bodyColor,
                                          fontSize: _bodyFontSize,
                                        ),
                                )
                              : TextField(
                                  controller: _bodyController,
                                  focusNode: _bodyFocusNode,
                                  cursorColor: bodyColor,
                                  style: AppFontManager.inputBody.copyWith(
                                    color: bodyColor,
                                    fontSize: _bodyFontSize.sp,
                                    height: 1.5,
                                  ),
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    hintText: 'addNoteBodyHint'.tr,
                                    hintStyle: AppFontManager.inputBody
                                        .copyWith(
                                          color: hintColor,
                                          fontSize: _bodyFontSize.sp,
                                          height: 1.5,
                                        ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                  ),
                                ),
                          AppSpacing.h40,
                        ],
                      ),
                    ),
                  ),
                ),

                // Formatting Toolbar
                NoteEditorToolbar(
                  isPreviewMode: _isPreviewMode,
                  isAutoSaving: _isAutoSaving,
                  bodyText: _bodyController.text,
                  currentNoteId: _currentNoteId,
                  hasCustomColor: hasCustomColor,
                  isDark: isDark,
                  customIsDark: customIsDark,
                  bodyColor: bodyColor,
                  secondaryTextColor: secondaryTextColor,
                  onShowColorPicker: _showColorPicker,
                  onShowAiAssistant: _showAiAssistant,
                  onInsertMarkdown: _insertMarkdown,
                  onShowHighlightColorPicker: _showHighlightColorPicker,
                  onShowTextColorPicker: _showTextColorPicker,
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
