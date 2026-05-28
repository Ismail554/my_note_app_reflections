import 'dart:async';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/widgets/note_save_button.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/shared/models/note_model.dart';
import 'package:Reflections/core/localization/app_translations.dart';
import 'package:Reflections/shared/widgets/markdown_text.dart';
import 'package:Reflections/features/add_new/presentation/widgets/meta_chip.dart';
import 'package:Reflections/features/add_new/presentation/widgets/toolbar_button.dart';
import 'package:Reflections/features/add_new/presentation/widgets/ai_assistant_panel.dart';
import 'package:Reflections/features/add_new/presentation/widgets/version_history_sheet.dart';

class AddNotePage extends StatefulWidget {
  final NoteModel? note;
  const AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _isSaving = false;
  late String _categoryName;

  // Custom Customizations
  int _selectedColor = 0;
  bool _isPinned = false;
  bool _isPreviewMode = false;

  // Auto-Save and Version History State
  Timer? _autoSaveTimer;
  String? _currentNoteId;
  String _lastSavedTitle = '';
  String _lastSavedBody = '';
  bool _isAutoSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _bodyController.text = widget.note!.description;
      _categoryName = widget.note!.category;
      _selectedColor = widget.note!.colorValue;
      _isPinned = widget.note!.isPinned;
      _isPreviewMode = true; // Open existing notes in Preview Mode by default!
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
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _autoSave();
    });
  }

  Future<void> _autoSave() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text;
    if (title.isEmpty) return;
    if (title == _lastSavedTitle && body == _lastSavedBody) return;

    if (!mounted) return;
    setState(() {
      _isAutoSaving = true;
    });

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
        final newId = await noteProvider.addNote(note);
        _currentNoteId = newId;
      }
      _lastSavedTitle = title;
      _lastSavedBody = body;
    } catch (e) {
      debugPrint('Auto-save error: $e');
    }

    if (mounted) {
      setState(() {
        _isAutoSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
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

    setState(() {
      _isSaving = true;
    });

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
    if (isEditing && noteId.isNotEmpty) {
      await noteProvider.updateNote(note);
    } else {
      await noteProvider.addNote(note);
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return VersionHistorySheet(
          currentNoteId: noteId,
          onRestore: (title, desc) {
            Navigator.pop(context);
            _restoreVersion(title, desc);
          },
        );
      },
    );
  }

  void _restoreVersion(String title, String desc) {
    setState(() {
      _titleController.text = title;
      _bodyController.text = desc;
      _isPreviewMode = false;
    });
    _autoSave();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Previous version restored successfully!'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.r),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  // Markdown Formatting Helper
  void _insertMarkdown(String prefix, String suffix) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;

    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0) {
      start = text.length;
      end = text.length;
    }

    final selectedText = text.substring(start, end);
    final replacement = '$prefix$selectedText$suffix';

    final newText = text.replaceRange(start, end, replacement);
    _bodyController.text = newText;

    _bodyController.selection = TextSelection.collapsed(
      offset: start + prefix.length + selectedText.length,
    );
    setState(() {});
  }

  // Curated Pastel Colors Picker bottom sheet
  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        final colors = [
          {'name': 'Default', 'value': 0},
          {'name': 'Cream', 'value': 0xFFFDF6EC},
          {'name': 'Sage', 'value': 0xFFF0F4F1},
          {'name': 'Mist', 'value': 0xFFEDF4F9},
          {'name': 'Lavender', 'value': 0xFFF6F0F8},
          {'name': 'Blush', 'value': 0xFFFAF0F0},
        ];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'noteColor'.tr,
                style: AppFontManager.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.h16,
              SizedBox(
                height: 60.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: colors.length,
                  separatorBuilder: (context, index) => AppSpacing.w16,
                  itemBuilder: (context, index) {
                    final colorItem = colors[index];
                    final value = colorItem['value'] as int;
                    final isSelected = _selectedColor == value;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = value;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: value == 0
                              ? AppColors.cardBackground
                              : Color(value),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryMedium
                                : AppColors.divider,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: AppColors.primaryMedium,
                                size: 20.sp,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              AppSpacing.h12,
            ],
          ),
        );
      },
    );
  }

  // Beautiful Text Color Picker Bottom Sheet
  void _showTextColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        final textColors = [
          {'name': 'Red', 'hex': '#EF5350', 'color': const Color(0xFFEF5350)},
          {'name': 'Green', 'hex': '#66BB6A', 'color': const Color(0xFF66BB6A)},
          {'name': 'Blue', 'hex': '#42A5F5', 'color': const Color(0xFF42A5F5)},
          {'name': 'Orange', 'hex': '#FFA726', 'color': const Color(0xFFFFA726)},
          {'name': 'Purple', 'hex': '#AB47BC', 'color': const Color(0xFFAB47BC)},
          {'name': 'Pink', 'hex': '#EC407A', 'color': const Color(0xFFEC407A)},
        ];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text Color',
                style: AppFontManager.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.h16,
              SizedBox(
                height: 60.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: textColors.length,
                  separatorBuilder: (context, index) => AppSpacing.w16,
                  itemBuilder: (context, index) {
                    final item = textColors[index];
                    final color = item['color'] as Color;
                    final hex = item['hex'] as String;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _insertMarkdown('<color=$hex>', '</color>');
                      },
                      child: Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              AppSpacing.h12,
            ],
          ),
        );
      },
    );
  }

  // Gemini AI Assistant Bottom Sheet dialog
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
      child: Scaffold(
        backgroundColor: canvasColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              // ─── Top Bar ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    // Close button
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: hasCustomColor
                              ? Colors.black.withValues(alpha: 0.05)
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
                    // Title
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

                    // Preview/Edit Toggle Button
                    IconButton(
                      icon: Icon(
                        _isPreviewMode
                            ? Icons.edit_outlined
                            : Icons.visibility_outlined,
                        color: secondaryTextColor,
                        size: 20.sp,
                      ),
                      tooltip: _isPreviewMode ? 'Edit Note' : 'Preview Note',
                      onPressed: () {
                        setState(() {
                          _isPreviewMode = !_isPreviewMode;
                        });
                      },
                    ),

                    // More Options Dropdown
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
                          setState(() {
                            _isPinned = !_isPinned;
                          });
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
                                _isPinned ? 'Unpin Note' : 'Pin Note',
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
                                  'Version History',
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
                                  'Archive Note',
                                  style: AppFontManager.bodyMedium.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Save button
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
                    ? Colors.black.withValues(alpha: 0.08)
                    : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
              ),

              // ─── Metadata row ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                child: Row(
                  children: [
                    MetaChip(
                      icon: Icons.calendar_today_outlined,
                      label: dateStr,
                      hasCustomColor: hasCustomColor,
                      isDark: isDark,
                    ),
                    AppSpacing.w10,
                    MetaChip(
                      icon: Icons.folder_outlined,
                      label: _categoryName,
                      hasCustomColor: hasCustomColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // ─── Editing area ─────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      _isPreviewMode
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text(
                                _titleController.text.isEmpty
                                    ? 'Untitled'
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
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'addNoteTitleHint'.tr,
                                hintStyle: AppFontManager.inputTitle.copyWith(
                                  color: hintColor,
                                ),
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
                            ? Colors.black.withValues(alpha: 0.08)
                            : (isDark
                                  ? AppColors.darkDivider
                                  : AppColors.lightDivider),
                      ),
                      AppSpacing.h12,

                      // Body field
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
                                            'No content yet.\nSwitch to edit mode to start writing!',
                                            textAlign: TextAlign.center,
                                            style: AppFontManager.bodyMedium
                                                .copyWith(
                                                  color: secondaryTextColor
                                                      .withValues(alpha: 0.82),
                                                  height: 1.4,
                                                ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : MarkdownText(
                                      text: _bodyController.text,
                                      textColor: bodyColor,
                                    ),
                            )
                          : TextField(
                              controller: _bodyController,
                              cursorColor: bodyColor,
                              style: AppFontManager.inputBody.copyWith(
                                color: bodyColor,
                              ),
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'addNoteBodyHint'.tr,
                                hintStyle: AppFontManager.inputBody.copyWith(
                                  color: hintColor,
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

              // ─── Formatting Helper Toolbar ────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: hasCustomColor
                      ? Colors.black.withValues(alpha: 0.03)
                      : (isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface),
                  border: Border(
                    top: BorderSide(
                      color: hasCustomColor
                          ? Colors.black.withValues(alpha: 0.08)
                          : AppColors.divider.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: _isPreviewMode
                      ? [
                          const Spacer(),
                          Builder(
                            builder: (context) {
                              final text = _bodyController.text.trim();
                              final words = text.isEmpty
                                  ? 0
                                  : text.split(RegExp(r'\s+')).length;
                              final readTime = (words / 200).ceil();
                              final saveStatus = _isAutoSaving
                                  ? ' • Saving...'
                                  : (_currentNoteId != null &&
                                            _currentNoteId!.isNotEmpty
                                        ? ' • Saved'
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
                            onPressed: _showColorPicker,
                          ),

                          // Sparkles AI Assistant button
                          IconButton(
                            icon: Icon(
                              Icons.auto_awesome_rounded,
                              color: const Color(0xFF8B5CF6), // Purple AI glow
                              size: 20.sp,
                            ),
                            tooltip: 'Gemini AI Assistant',
                            onPressed: _showAiAssistant,
                          ),

                          Container(
                            height: 20.h,
                            width: 1.w,
                            color: hasCustomColor
                                ? Colors.black.withValues(alpha: 0.08)
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
                                    onPressed: () =>
                                        _insertMarkdown('**', '**'),
                                  ),
                                  ToolbarButton(
                                    icon: Icons.format_italic_rounded,
                                    color: bodyColor,
                                    onPressed: () => _insertMarkdown('*', '*'),
                                  ),
                                  ToolbarButton(
                                    icon: Icons.format_underlined_rounded,
                                    color: bodyColor,
                                    onPressed: () =>
                                        _insertMarkdown('<u>', '</u>'),
                                  ),
                                  ToolbarButton(
                                    icon: Icons.border_color_rounded, // Highlight icon
                                    color: bodyColor,
                                    onPressed: () =>
                                        _insertMarkdown('==', '=='),
                                  ),
                                  ToolbarButton(
                                    icon: Icons.format_color_text_rounded, // Color change icon
                                    color: bodyColor,
                                    onPressed: _showTextColorPicker,
                                  ),
                                  ToolbarButton(
                                    icon: Icons.title_rounded,
                                    color: bodyColor,
                                    onPressed: () => _insertMarkdown('# ', ''),
                                  ),
                                  ToolbarButton(
                                    icon: Icons.format_list_bulleted_rounded,
                                    color: bodyColor,
                                    onPressed: () => _insertMarkdown('- ', ''),
                                  ),
                                  ToolbarButton(
                                    icon: Icons.checklist_rounded,
                                    color: bodyColor,
                                    onPressed: () =>
                                        _insertMarkdown('- [ ] ', ''),
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
                                final text = _bodyController.text.trim();
                                final words = text.isEmpty
                                    ? 0
                                    : text.split(RegExp(r'\s+')).length;
                                final saveStatus = _isAutoSaving
                                    ? 'Saving...'
                                    : (_currentNoteId != null &&
                                              _currentNoteId!.isNotEmpty
                                          ? 'Saved'
                                          : '');

                                return Text(
                                  saveStatus.isNotEmpty
                                      ? '$words w • $saveStatus'
                                      : '$words w',
                                  style: AppFontManager.bodySmall.copyWith(
                                    fontSize: 10.sp,
                                    color: _isAutoSaving
                                        ? const Color(0xFF8B5CF6)
                                        : secondaryTextColor.withValues(
                                            alpha: 0.85,
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
