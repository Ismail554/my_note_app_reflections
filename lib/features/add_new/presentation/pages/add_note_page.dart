import 'package:Reflections/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/widgets/note_save_button.dart';
import 'package:Reflections/features/home/presentation/controller/home_controller.dart';
import 'package:Reflections/shared/models/note_model.dart';

class AddNotePage extends StatefulWidget {
  final NoteModel? note;
  const AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _isSaving = false.obs;
  late String _categoryName;
  
  // Custom Customizations
  final RxInt _selectedColor = 0.obs;
  final RxBool _isPinned = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _bodyController.text = widget.note!.description;
      _categoryName = widget.note!.category;
      _selectedColor.value = widget.note!.colorValue;
      _isPinned.value = widget.note!.isPinned;
    } else {
      _selectedColor.value = 0;
      _isPinned.value = false;
      if (Get.isRegistered<HomeController>()) {
        final hc = Get.find<HomeController>();
        _categoryName = hc.selectedFolder.value == 'All'
            ? 'Reflections'
            : hc.selectedFolder.value;
      } else {
        _categoryName = 'Reflections';
      }
    }

    _bodyController.addListener(() {
      // Re-trigger build on text change for live word/character statistics
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

    _isSaving.value = true;

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
      colorValue: _selectedColor.value,
      isPinned: _isPinned.value,
    );

    // Save/Update in Controller
    if (Get.isRegistered<HomeController>()) {
      if (isEditing) {
        await Get.find<HomeController>().updateNote(note);
      } else {
        await Get.find<HomeController>().addNote(note);
      }
    }

    _isSaving.value = false;
    if (context.mounted) context.pop();
  }

  void _archiveNote(BuildContext context) {
    if (widget.note == null) return;
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().archiveNote(widget.note!.id);
    }
    context.pop();
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
                  separatorBuilder: (_, __) => AppSpacing.w16,
                  itemBuilder: (context, index) {
                    final colorItem = colors[index];
                    final value = colorItem['value'] as int;
                    final isSelected = _selectedColor.value == value;
                    
                    return GestureDetector(
                      onTap: () {
                        _selectedColor.value = value;
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

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMMM d, y').format(
      widget.note != null ? widget.note!.createdAt : DateTime.now(),
    );

    return Obx(() {
      final canvasColor = _selectedColor.value == 0
          ? AppColors.background
          : Color(_selectedColor.value);

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
                        onTap: () => context.pop(),
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
                          _isPinned.value ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                          color: _isPinned.value ? const Color(0xFFC6A052) : AppColors.textSecondary,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          _isPinned.toggle();
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
                      Obx(
                        () => AppSaveButton(
                          isLoading: _isSaving.value,
                          onPressed: () => _save(context),
                        ),
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
    });
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
