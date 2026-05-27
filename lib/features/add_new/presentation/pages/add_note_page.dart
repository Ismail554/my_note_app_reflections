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
import 'package:Reflections/core/services/gemini_service.dart';
import 'package:Reflections/core/localization/app_translations.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _bodyController.text = widget.note!.description;
      _categoryName = widget.note!.category;
      _selectedColor = widget.note!.colorValue;
      _isPinned = widget.note!.isPinned;
    } else {
      _selectedColor = 0;
      _isPinned = false;
      // Get category from NoteProvider
      final noteProvider = context.read<NoteProvider>();
      _categoryName = noteProvider.selectedFolder == 'All'
          ? 'Reflections'
          : noteProvider.selectedFolder;
    }

    _bodyController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
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

    final isEditing = widget.note != null;
    final note = NoteModel(
      id: isEditing ? widget.note!.id : '',
      title: title,
      description: _bodyController.text.trim(),
      createdAt: isEditing ? widget.note!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      userId: isEditing ? widget.note!.userId : '',
      category: _categoryName,
      isArchived: isEditing ? widget.note!.isArchived : false,
      colorValue: _selectedColor,
      isPinned: _isPinned,
    );

    final noteProvider = context.read<NoteProvider>();
    final navigator = Navigator.of(context);
    if (isEditing) {
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

  void _archiveNote(BuildContext context) {
    if (widget.note == null) return;
    context.read<NoteProvider>().archiveNote(widget.note!.id, true);
    Navigator.of(context).pop();
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
                          color: value == 0 ? AppColors.cardBackground : Color(value),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primaryMedium : AppColors.divider,
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

  // Gemini AI Assistant Bottom Sheet dialog
  void _showAiAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AiAssistantPanel(
        titleController: _titleController,
        bodyController: _bodyController,
        onUpdate: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMMM d, y').format(
      widget.note != null ? widget.note!.createdAt : DateTime.now(),
    );

    final canvasColor = _selectedColor == 0
        ? AppColors.background
        : Color(_selectedColor);

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
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 18.sp,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Title
                    Text(
                      widget.note != null ? 'addNoteEdit'.tr : 'addNoteTitle'.tr,
                      style: AppFontManager.headlineMedium,
                    ),
                    const Spacer(),

                    // Pin Button
                    IconButton(
                      icon: Icon(
                        _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                        color: _isPinned ? const Color(0xFFC6A052) : AppColors.textSecondary,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPinned = !_isPinned;
                        });
                      },
                    ),

                    // Delete/Archive button
                    if (widget.note != null) ...[
                      InkWell(
                        onTap: () => _archiveNote(context),
                        child: Container(
                          width: 36.w,
                          height: 36.h,
                          margin: EdgeInsets.only(right: 12.w, left: 4.w),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],

                    // Save button
                    AppSaveButton(
                      isLoading: _isSaving,
                      onPressed: () => _save(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ─── Metadata row ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                child: Row(
                  children: [
                    _MetaChip(
                      icon: Icons.calendar_today_outlined,
                      label: dateStr,
                    ),
                    AppSpacing.w10,
                    _MetaChip(icon: Icons.folder_outlined, label: _categoryName),
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
                      TextField(
                        textInputAction: TextInputAction.next,
                        controller: _titleController,
                        style: AppFontManager.inputTitle,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'addNoteTitleHint'.tr,
                          hintStyle: AppFontManager.inputTitleHint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                      ),
                      AppSpacing.h12,

                      const Divider(color: AppColors.divider),
                      AppSpacing.h12,

                      // Body field
                      TextField(
                        controller: _bodyController,
                        style: AppFontManager.inputBody,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'addNoteBodyHint'.tr,
                          hintStyle: AppFontManager.inputBodyHint,
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
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Color picker launcher
                    IconButton(
                      icon: Icon(
                        Icons.palette_outlined,
                        color: AppColors.primaryMedium,
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
                      color: AppColors.divider,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                    ),

                    // Formatting helpers
                    _ToolbarButton(
                      icon: Icons.format_bold_rounded,
                      onPressed: () => _insertMarkdown('**', '**'),
                    ),
                    _ToolbarButton(
                      icon: Icons.format_italic_rounded,
                      onPressed: () => _insertMarkdown('*', '*'),
                    ),
                    _ToolbarButton(
                      icon: Icons.format_underlined_rounded,
                      onPressed: () => _insertMarkdown('<u>', '</u>'),
                    ),
                    _ToolbarButton(
                      icon: Icons.title_rounded,
                      onPressed: () => _insertMarkdown('# ', ''),
                    ),
                    _ToolbarButton(
                      icon: Icons.format_list_bulleted_rounded,
                      onPressed: () => _insertMarkdown('- ', ''),
                    ),
                    _ToolbarButton(
                      icon: Icons.checklist_rounded,
                      onPressed: () => _insertMarkdown('- [ ] ', ''),
                    ),

                    const Spacer(),

                    // Statistics (Word Count & Reading Time)
                    Builder(builder: (context) {
                      final text = _bodyController.text.trim();
                      final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
                      final readTime = (words / 200).ceil();
                      
                      return Text(
                        '$words ${'wordCount'.tr} • $readTime ${'readTime'.tr}',
                        style: AppFontManager.bodySmall.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                      );
                    }),
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.h10v6,
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.chipBorder, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: AppColors.primaryMedium),
          AppSpacing.w6,
          Text(
            label,
            style: AppFontManager.labelMedium.copyWith(
              color: AppColors.primaryMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ToolbarButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: AppColors.textSecondary, size: 18.sp),
      onPressed: onPressed,
    );
  }
}

// ─── Gemini AI Assistant Panel ─────────────────────────────────────────────
class _AiAssistantPanel extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final VoidCallback onUpdate;

  const _AiAssistantPanel({
    required this.titleController,
    required this.bodyController,
    required this.onUpdate,
  });

  @override
  State<_AiAssistantPanel> createState() => _AiAssistantPanelState();
}

class _AiAssistantPanelState extends State<_AiAssistantPanel> {
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
      result = await GeminiService.instance.improveText(widget.bodyController.text);
    } else if (action == 'title') {
      result = await GeminiService.instance.suggestTitle(
        widget.titleController.text,
        widget.bodyController.text,
      );
    } else if (action == 'pronounce') {
      result = await GeminiService.instance.fixMispronunciations(widget.bodyController.text);
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
    return Container(
      padding: EdgeInsets.only(
        top: 20.h,
        left: 24.w,
        right: 24.w,
        bottom: 32.h + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: const Color(0xFF8B5CF6), size: 24.sp),
              AppSpacing.w8,
              Text(
                'Gemini AI Note Assistant',
                style: AppFontManager.headlineLarge.copyWith(fontSize: 20.sp),
              ),
            ],
          ),
          AppSpacing.h4,
          Text(
            'Refine spelling, fix verbal slips, or generate ideas with AI.',
            style: AppFontManager.bodySmall,
          ),
          AppSpacing.h20,

          if (_aiResult.isEmpty && !_isLoading) ...[
            // Actions Selection Grid
            Row(
              children: [
                Expanded(
                  child: _AiCard(
                    icon: Icons.auto_fix_high_rounded,
                    label: 'Polish Note',
                    subLabel: 'Grammar & Flow',
                    onTap: () => _triggerAction('improve'),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: _AiCard(
                    icon: Icons.title_rounded,
                    label: 'Suggest Title',
                    subLabel: 'Auto-generate title',
                    onTap: () => _triggerAction('title'),
                  ),
                ),
              ],
            ),
            AppSpacing.h12,
            _AiCard(
              icon: Icons.record_voice_over_rounded,
              label: 'Fix Voice Transcription Mistakes',
              subLabel: 'Fix phonetic misspellings & mispronunciations',
              onTap: () => _triggerAction('pronounce'),
            ),
          ] else ...[
            // Output / Loading panel
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: _isLoading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppSpacing.h24,
                        const CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                        AppSpacing.h16,
                        Text(
                          'Gemini is working its magic...',
                          style: AppFontManager.bodyMedium.copyWith(fontStyle: FontStyle.italic),
                        ),
                        AppSpacing.h24,
                      ],
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _aiResult,
                        style: AppFontManager.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
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
                        style: AppFontManager.buttonSmall.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final VoidCallback onTap;

  const _AiCard({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.primarySurface.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primarySurface, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: const BoxDecoration(
                color: Colors.white,
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
                    style: AppFontManager.headlineMedium.copyWith(fontSize: 14.sp),
                  ),
                  AppSpacing.h2,
                  Text(
                    subLabel,
                    style: AppFontManager.caption,
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
