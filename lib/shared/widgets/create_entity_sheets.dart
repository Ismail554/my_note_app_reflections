import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/features/habit/state/habit_provider.dart';
import 'package:Reflections/features/todo/state/todo_provider.dart';
import 'package:Reflections/features/reminder/state/reminder_provider.dart';

class CreateEntitySheets {
  CreateEntitySheets._();

  // ═══════════════════════════════════════════════════════════════════════
  //  TASK SHEET — with priority, due date, description, quick-date chips
  // ═══════════════════════════════════════════════════════════════════════
  static Future<void> showAddTaskSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'Medium';
    DateTime? dueDate;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24.w, 20.h, 24.w,
            MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.add_task_rounded, color: AppColors.mediumGreen, size: 22.sp),
                    SizedBox(width: 8.w),
                    Text('New Task', style: AppFontManager.headingLarge.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    )),
                  ],
                ),
                SizedBox(height: 16.h),

                // Title
                TextField(
                  controller: titleCtrl,
                  autofocus: true,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  decoration: const InputDecoration(hintText: 'What needs to be done?'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 12.h),

                // Description (new)
                TextField(
                  controller: descCtrl,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  decoration: const InputDecoration(hintText: 'Add details (optional)'),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                ),
                SizedBox(height: 16.h),

                // Priority label
                Text('Priority', style: AppFontManager.labelMedium.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                )),
                SizedBox(height: 8.h),

                // Priority chips
                Row(
                  children: ['Low', 'Medium', 'High'].map((p) {
                    final sel = priority == p;
                    Color c = AppColors.priorityMedium;
                    if (p == 'Low') c = AppColors.priorityLow;
                    if (p == 'High') c = AppColors.priorityHigh;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: sel ? c.withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: sel ? c : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                              width: sel ? 1.5 : 0.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(p, style: AppFontManager.labelMedium.copyWith(
                            color: sel ? c : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          )),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),

                // Quick-date chips (new)
                Text('Due Date', style: AppFontManager.labelMedium.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                )),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    _quickDateChip('Today', DateTime.now(), dueDate, isDark, (d) => setState(() => dueDate = d)),
                    _quickDateChip('Tomorrow', DateTime.now().add(const Duration(days: 1)), dueDate, isDark, (d) => setState(() => dueDate = d)),
                    _quickDateChip('Next Week', DateTime.now().add(const Duration(days: 7)), dueDate, isDark, (d) => setState(() => dueDate = d)),
                    ActionChip(
                      avatar: Icon(Icons.calendar_today_rounded, size: 14.sp),
                      label: Text(dueDate != null ? DateFormat('MMM d').format(dueDate!) : 'Pick Date'),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d != null) setState(() => dueDate = d);
                      },
                    ),
                    if (dueDate != null)
                      ActionChip(
                        avatar: Icon(Icons.clear_rounded, size: 14.sp, color: AppColors.error),
                        label: const Text('Clear'),
                        onPressed: () => setState(() => dueDate = null),
                      ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Add Task'),
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      context.read<TodoProvider>().addTodo(
                        titleCtrl.text.trim(),
                        priority,
                        dueDate,
                      );
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.cream,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  HABIT SHEET — with icon, target days, frequency, color
  // ═══════════════════════════════════════════════════════════════════════
  static Future<void> showAddHabitSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedIcon = '🎯';
    int targetDays = 7;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final icons = ['🎯', '💪', '📚', '🧘', '🏃', '💧', '🎨', '🎵', '✍️', '🌅', '💤', '🥗', '🧠', '🏋️', '🚶', '☕'];

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20.w, 20.h, 20.w,
            MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(selectedIcon, style: TextStyle(fontSize: 22.sp)),
                    SizedBox(width: 8.w),
                    Text('New Habit', style: AppFontManager.headingLarge.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    )),
                  ],
                ),
                SizedBox(height: 16.h),

                // Icon picker
                Text('Choose Icon', style: AppFontManager.labelMedium.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                )),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: icons.map((icon) {
                    final sel = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primaryGreen.withValues(alpha: 0.2)
                              : (isDark ? AppColors.darkInputFill : AppColors.lightInputFill),
                          border: Border.all(
                            color: sel ? AppColors.primaryGreen : (isDark ? AppColors.darkInputBorder : AppColors.lightInputBorder),
                            width: sel ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(icon, style: TextStyle(fontSize: 20.sp)),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),

                // Name
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  decoration: const InputDecoration(hintText: 'Habit name (e.g. Daily Meditation)'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 12.h),

                // Description
                TextField(
                  controller: descCtrl,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  decoration: const InputDecoration(hintText: 'Motivation or notes'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 16.h),

                // Target days per week (new)
                Text('Frequency', style: AppFontManager.labelMedium.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                )),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        targetDays == 7
                            ? 'Every day'
                            : '$targetDays days / week',
                        style: AppFontManager.bodyMedium.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Stepper
                    _stepperButton(Icons.remove_rounded, isDark, () {
                      if (targetDays > 1) setState(() => targetDays--);
                    }),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text('$targetDays', style: AppFontManager.headingMedium.copyWith(
                        color: AppColors.primaryGreen,
                      )),
                    ),
                    _stepperButton(Icons.add_rounded, isDark, () {
                      if (targetDays < 7) setState(() => targetDays++);
                    }),
                  ],
                ),
                SizedBox(height: 8.h),

                // Visual frequency dots (new)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (i) {
                    final active = i < targetDays;
                    return Container(
                      width: 28.r,
                      height: 28.r,
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? AppColors.primaryGreen.withValues(alpha: 0.2)
                            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                        border: Border.all(
                          color: active ? AppColors.primaryGreen : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? AppColors.primaryGreen
                                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 24.h),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Create Habit'),
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      context.read<HabitProvider>().addHabit(
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        icon: selectedIcon,
                        targetDaysPerWeek: targetDays,
                      );
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.cream,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  REMINDER SHEET — with repeat, alarm toggle, quick-time chips
  // ═══════════════════════════════════════════════════════════════════════
  static Future<void> showAddReminderSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? selectedDateTime;
    bool isAlarm = false;
    String repeatType = 'none';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20.w, 20.h, 20.w,
            MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.alarm_add_rounded, color: const Color(0xFF2980B9), size: 22.sp),
                    SizedBox(width: 8.w),
                    Text('Schedule Reminder', style: AppFontManager.headingLarge.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    )),
                  ],
                ),
                SizedBox(height: 16.h),

                // Title
                TextField(
                  controller: titleCtrl,
                  autofocus: true,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  decoration: const InputDecoration(hintText: 'Reminder title'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 12.h),

                // Description
                TextField(
                  controller: descCtrl,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  decoration: const InputDecoration(hintText: 'Extra details (optional)'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 16.h),

                // Quick time chips (new)
                Text('When', style: AppFontManager.labelMedium.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                )),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    _quickTimeChip('In 30 min', 30, selectedDateTime, isDark, (d) => setState(() => selectedDateTime = d)),
                    _quickTimeChip('In 1 hour', 60, selectedDateTime, isDark, (d) => setState(() => selectedDateTime = d)),
                    _quickTimeChip('In 3 hours', 180, selectedDateTime, isDark, (d) => setState(() => selectedDateTime = d)),
                    _quickTimeChip('Tomorrow 9 AM', -1, selectedDateTime, isDark, (d) => setState(() => selectedDateTime = d)),
                    ActionChip(
                      avatar: Icon(Icons.schedule_rounded, size: 14.sp),
                      label: Text(selectedDateTime != null
                          ? DateFormat('MMM d, h:mm a').format(selectedDateTime!)
                          : 'Custom'),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date == null || !ctx.mounted) return;
                        final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                        if (time == null) return;
                        setState(() {
                          selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Repeat type (new)
                Text('Repeat', style: AppFontManager.labelMedium.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                )),
                SizedBox(height: 8.h),
                Row(
                  children: ['none', 'daily', 'weekly', 'monthly'].map((r) {
                    final sel = repeatType == r;
                    final label = r == 'none' ? 'Once' : r[0].toUpperCase() + r.substring(1);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => repeatType = r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF2980B9).withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: sel ? const Color(0xFF2980B9) : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                              width: sel ? 1.5 : 0.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(label, style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel ? const Color(0xFF2980B9) : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          )),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),

                // Alarm toggle
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isAlarm
                        ? AppColors.error.withValues(alpha: 0.08)
                        : (isDark ? AppColors.darkInputFill : AppColors.lightInputFill),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isAlarm ? AppColors.error.withValues(alpha: 0.3) : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAlarm ? Icons.alarm_on_rounded : Icons.notifications_none_rounded,
                        size: 20.sp,
                        color: isAlarm ? AppColors.error : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('High-Priority Alarm', style: AppFontManager.bodyMedium.copyWith(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w600,
                            )),
                            Text('Looping sound until dismissed', style: AppFontManager.caption.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            )),
                          ],
                        ),
                      ),
                      Switch(value: isAlarm, onChanged: (v) => setState(() => isAlarm = v)),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.alarm_add_rounded),
                    label: const Text('Schedule'),
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty || selectedDateTime == null) return;
                      context.read<ReminderProvider>().addReminder(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        triggerTime: selectedDateTime!,
                        isAlarm: isAlarm,
                        repeatType: repeatType,
                      );
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2980B9),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  /// Quick date chip for task sheet.
  static Widget _quickDateChip(
    String label,
    DateTime date,
    DateTime? current,
    bool isDark,
    ValueChanged<DateTime> onSelect,
  ) {
    final normalized = DateTime(date.year, date.month, date.day);
    final isSelected = current != null &&
        current.year == normalized.year &&
        current.month == normalized.month &&
        current.day == normalized.day;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primaryGreen,
      onSelected: (_) => onSelect(normalized),
    );
  }

  /// Quick time chip for reminder sheet. minutesFromNow == -1 means "tomorrow 9 AM".
  static Widget _quickTimeChip(
    String label,
    int minutesFromNow,
    DateTime? current,
    bool isDark,
    ValueChanged<DateTime> onSelect,
  ) {
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 12.sp)),
      onPressed: () {
        DateTime target;
        if (minutesFromNow == -1) {
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          target = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
        } else {
          target = DateTime.now().add(Duration(minutes: minutesFromNow));
        }
        onSelect(target);
      },
    );
  }

  /// Stepper +/- button for habit frequency.
  static Widget _stepperButton(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Icon(icon, size: 18.sp, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ),
    );
  }
}
