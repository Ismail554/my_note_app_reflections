import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/features/todo/data/models/todo_model.dart';
import 'package:Reflections/features/todo/state/todo_provider.dart';
import 'package:Reflections/shared/widgets/empty_state.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final _titleController = TextEditingController();
  String _selectedPriority = 'Medium';
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddTodoSheet(BuildContext context) {
    _titleController.clear();
    _selectedPriority = 'Medium';
    _selectedDueDate = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Task', style: AppFontManager.headlineMedium),
                  AppSpacing.h16,

                  // Title input
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    style: AppFontManager.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      hintStyle: AppFontManager.bodyMedium.copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                    ),
                  ),
                  AppSpacing.h16,

                  // Priority buttons
                  Text('Priority', style: AppFontManager.labelMedium),
                  AppSpacing.h8,
                  Row(
                    children: ['Low', 'Medium', 'High'].map((p) {
                      final isSelected = _selectedPriority == p;
                      Color pColor = AppColors.primaryMedium;
                      if (p == 'Low') pColor = Colors.blue;
                      if (p == 'High') pColor = AppColors.error;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => _selectedPriority = p),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isSelected ? pColor.withValues(alpha: 0.15) : AppColors.surface,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isSelected ? pColor : AppColors.divider,
                                width: isSelected ? 1.8 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              p,
                              style: AppFontManager.labelMedium.copyWith(
                                color: isSelected ? pColor : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  AppSpacing.h16,

                  // Due Date picker
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 18.sp, color: AppColors.primaryMedium),
                      AppSpacing.w8,
                      Text(
                        _selectedDueDate == null
                            ? 'No due date set'
                            : 'Due: ${DateFormat('MMM d, y').format(_selectedDueDate!)}',
                        style: AppFontManager.bodyMedium.copyWith(
                          color: _selectedDueDate == null ? AppColors.textHint : AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() => _selectedDueDate = picked);
                          }
                        },
                        child: Text('Set Date', style: AppFontManager.link),
                      ),
                    ],
                  ),
                  AppSpacing.h24,

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        if (_titleController.text.trim().isEmpty) return;
                        context.read<TodoProvider>().addTodo(
                              _titleController.text,
                              _selectedPriority,
                              _selectedDueDate,
                            );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Add Task',
                        style: AppFontManager.buttonLarge.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryMedium));
        }

        if (provider.todos.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: EmptyState(
              message: 'Checklist is currently empty.',
              actionLabel: 'Create Task',
              onAction: () => _showAddTodoSheet(context),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTodoSheet(context),
            tooltip: 'Add Task',
            child: Icon(Icons.add_rounded, size: 24.sp),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              // ─── Progress Card ──────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Task Progress', style: AppFontManager.headlineMedium),
                        Text(
                          '${provider.completedCount}/${provider.todos.length}',
                          style: AppFontManager.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    AppSpacing.h8,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: provider.progressRatio,
                        minHeight: 8.h,
                        backgroundColor: AppColors.surfaceVariant,
                        color: AppColors.primaryMedium,
                      ),
                    ),
                    AppSpacing.h6,
                    Text(
                      provider.progressRatio == 1.0
                          ? 'Hurray! All tasks completed today! 🎉'
                          : '${(provider.progressRatio * 100).toInt()}% completed',
                      style: AppFontManager.bodySmall,
                    ),
                  ],
                ),
              ),
              AppSpacing.h16,

              // ─── Active Task List ───────────────────────────────────────
              ...provider.todos.map((todo) => _buildTodoCard(context, todo)),
              AppSpacing.h80,
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodoCard(BuildContext context, TodoModel todo) {
    Color pColor = AppColors.primaryMedium;
    if (todo.priority == 'Low') pColor = Colors.blue;
    if (todo.priority == 'High') pColor = AppColors.error;

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<TodoProvider>().deleteTodo(todo.id);
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(Icons.delete_outline_rounded, color: AppColors.white, size: 22.sp),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Row(
          children: [
            // Checked indicator checkbox
            GestureDetector(
              onTap: () {
                context.read<TodoProvider>().toggleTodoStatus(todo);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: todo.isCompleted ? AppColors.primaryMedium : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: todo.isCompleted ? AppColors.primaryMedium : AppColors.divider,
                    width: 2,
                  ),
                ),
                child: todo.isCompleted
                    ? Icon(Icons.check, size: 14.r, color: AppColors.white)
                    : null,
              ),
            ),
            AppSpacing.w12,

            // Todo core content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: AppFontManager.bodyMedium.copyWith(
                      color: todo.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (todo.dueDate != null) ...[
                    AppSpacing.h4,
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 10.sp, color: AppColors.textMuted),
                        AppSpacing.w4,
                        Text(
                          DateFormat('E, MMM d').format(todo.dueDate!),
                          style: AppFontManager.bodySmall.copyWith(fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Priority dot and tag
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: pColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: BoxDecoration(color: pColor, shape: BoxShape.circle),
                  ),
                  AppSpacing.w6,
                  Text(
                    todo.priority,
                    style: AppFontManager.labelMedium.copyWith(
                      color: pColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
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
