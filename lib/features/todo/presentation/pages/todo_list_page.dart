import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24.w, 24.h, 24.w,
                MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Task', style: AppFontManager.headingLarge.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  )),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'What needs to be done?'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: 16.h),
                  Text('Priority', style: AppFontManager.labelMedium.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  )),
                  SizedBox(height: 8.h),
                  Row(
                    children: ['Low', 'Medium', 'High'].map((p) {
                      final isSelected = _selectedPriority == p;
                      Color pColor = AppColors.priorityMedium;
                      if (p == 'Low') pColor = AppColors.priorityLow;
                      if (p == 'High') pColor = AppColors.priorityHigh;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => _selectedPriority = p),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isSelected ? pColor.withValues(alpha: 0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isSelected ? pColor : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                                width: isSelected ? 1.5 : 0.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              p,
                              style: AppFontManager.labelMedium.copyWith(
                                color: isSelected ? pColor : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 18.sp, color: AppColors.accent),
                      SizedBox(width: 8.w),
                      Text(
                        _selectedDueDate == null
                            ? 'No due date set'
                            : 'Due: ${DateFormat('MMM d, y').format(_selectedDueDate!)}',
                        style: AppFontManager.bodyMedium.copyWith(
                          color: _selectedDueDate == null
                              ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() => _selectedDueDate = picked);
                          }
                        },
                        child: const Text('Set Date'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.trim().isEmpty) return;
                        context.read<TodoProvider>().addTodo(
                              _titleController.text,
                              _selectedPriority,
                              _selectedDueDate,
                            );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Add Task'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppColors.accent));
        }

        if (provider.todos.isEmpty) {
          return EmptyState(
            message: 'Checklist is currently empty.',
            actionLabel: 'Create Task',
            onAction: () => _showAddTodoSheet(context),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTodoSheet(context),
            tooltip: 'Add Task',
            child: Icon(Icons.add_rounded, size: 24.sp),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              // ─── Progress Card ───────────────────────────────────
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Task Progress', style: AppFontManager.headingMedium.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        )),
                        Text(
                          '${provider.completedCount}/${provider.todos.length}',
                          style: AppFontManager.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: provider.progressRatio,
                        minHeight: 6.h,
                        backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      provider.progressRatio == 1.0
                          ? 'All tasks completed! 🎉'
                          : '${(provider.progressRatio * 100).toInt()}% completed',
                      style: AppFontManager.caption.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // ─── Todo Cards ──────────────────────────────────────
              ...provider.todos.map((todo) => _buildTodoCard(context, todo, isDark)),
              SizedBox(height: 80.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodoCard(BuildContext context, TodoModel todo, bool isDark) {
    Color pColor = AppColors.priorityMedium;
    if (todo.priority == 'Low') pColor = AppColors.priorityLow;
    if (todo.priority == 'High') pColor = AppColors.priorityHigh;

    return Dismissible(
      key: Key('${todo.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        if (todo.id != null) context.read<TodoProvider>().deleteTodo(todo.id!);
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22.sp),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => context.read<TodoProvider>().toggleTodoStatus(todo),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  color: todo.isCompleted ? AppColors.accent : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: todo.isCompleted ? AppColors.accent : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    width: 1.5,
                  ),
                ),
                child: todo.isCompleted
                    ? Icon(Icons.check, size: 14.r, color: AppColors.white)
                    : null,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: AppFontManager.bodyMedium.copyWith(
                      color: todo.isCompleted
                          ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (todo.dueDate != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 10.sp,
                          color: todo.isOverdue ? AppColors.error : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                        SizedBox(width: 4.w),
                        Text(
                          DateFormat('E, MMM d').format(todo.dueDate!),
                          style: AppFontManager.caption.copyWith(
                            fontSize: 10.sp,
                            color: todo.isOverdue ? AppColors.error : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Priority tag
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: pColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                todo.priority,
                style: AppFontManager.caption.copyWith(
                  color: pColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
