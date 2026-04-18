import 'package:Reflections/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:Reflections/core/constants/app_strings.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/widgets/custom_button.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _bodyController.text = widget.note!.description;
      _categoryName = widget.note!.category;
    } else {
      if (Get.isRegistered<HomeController>()) {
        final hc = Get.find<HomeController>();
        _categoryName = hc.selectedFolder.value == 'All'
            ? 'Reflections'
            : hc.selectedFolder.value;
      } else {
        _categoryName = 'Reflections';
      }
    }
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
          content: const Text('Please give your note a title before saving.'),
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

    // model creation
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
    );

    // Add to home controller
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

  // archive note
  void _archiveNote(BuildContext context) {
    if (widget.note == null) return;
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().archiveNote(widget.note!.id);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMMM d, y').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    widget.note != null ? 'Edit Note' : AppStrings.addNoteTitle,
                    style: AppFontManager.headlineMedium,
                  ),
                  const Spacer(),
                  // delete button / archive
                  if (widget.note != null) ...[
                    InkWell(
                      onTap: () => _archiveNote(context),
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        margin: EdgeInsets.only(right: 12.w),
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
                      textInputAction: .next,
                      controller: _titleController,
                      style: AppFontManager.inputTitle,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: AppStrings.addNoteTitleHint,
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
                        hintText: AppStrings.addNoteBodyHint,
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
          ],
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
