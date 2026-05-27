import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
import 'package:Reflections/features/habit/data/models/habit_model.dart';
import 'package:Reflections/features/habit/state/habit_provider.dart';
import 'package:Reflections/shared/widgets/empty_state.dart';

class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({super.key});

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  List<DateTime> _getLast7Days() {
    return List.generate(
      7,
      (index) => DateTime.now().subtract(Duration(days: 6 - index)),
    );
  }

  void _showAddHabitSheet(BuildContext context) {
    _nameController.clear();
    _descController.clear();
    _selectedTime = null;

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
                  Text('New Habit', style: AppFontManager.headlineMedium),
                  AppSpacing.h16,

                  // Name Input
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    style: AppFontManager.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Habit Name (e.g. Read Books, Meditate)',
                      hintStyle: AppFontManager.bodyMedium.copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                    ),
                  ),
                  AppSpacing.h12,

                  // Description Input
                  TextField(
                    controller: _descController,
                    style: AppFontManager.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Description or Goal',
                      hintStyle: AppFontManager.bodyMedium.copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                    ),
                  ),
                  AppSpacing.h16,

                  // Time reminder setting
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 18.sp, color: AppColors.primaryMedium),
                      AppSpacing.w8,
                      Text(
                        _selectedTime == null
                            ? 'No dynamic reminder alarm set'
                            : 'Remind me at: ${_selectedTime!.format(context)}',
                        style: AppFontManager.bodyMedium.copyWith(
                          color: _selectedTime == null ? AppColors.textHint : AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setModalState(() => _selectedTime = picked);
                          }
                        },
                        child: Text('Set Time', style: AppFontManager.link),
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
                        if (_nameController.text.trim().isEmpty) return;
                        String? alarmStr;
                        if (_selectedTime != null) {
                          final hr = _selectedTime!.hour.toString().padLeft(2, '0');
                          final min = _selectedTime!.minute.toString().padLeft(2, '0');
                          alarmStr = '$hr:$min';
                        }
                        context.read<HabitProvider>().addHabit(
                              _nameController.text,
                              _descController.text,
                              alarmStr,
                            );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Add Habit',
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
    final days = _getLast7Days();

    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryMedium));
        }

        if (provider.habits.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: EmptyState(
              message: 'Start tracking daily habits today.',
              actionLabel: 'Create Habit',
              onAction: () => _showAddHabitSheet(context),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddHabitSheet(context),
            tooltip: 'Add Habit',
            child: Icon(Icons.add_rounded, size: 24.sp),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              ...provider.habits.map((habit) => _buildHabitCard(context, habit, days)),
              AppSpacing.h80,
            ],
          ),
        );
      },
    );
  }

  Widget _buildHabitCard(BuildContext context, HabitModel habit, List<DateTime> days) {
    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<HabitProvider>().deleteHabit(habit.id);
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Icons.delete_outline_rounded, color: AppColors.white, size: 22.sp),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit Info & Streak Counter
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: AppFontManager.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (habit.description.isNotEmpty) ...[
                        AppSpacing.h2,
                        Text(
                          habit.description,
                          style: AppFontManager.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.w12,

                // Streak Flame
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 16.sp),
                      AppSpacing.w4,
                      Text(
                        '${habit.streakCount} d',
                        style: AppFontManager.labelMedium.copyWith(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.h16,

            // 7 Days Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((day) {
                final dateStr = day.toIso8601String().substring(0, 10);
                final isCompleted = habit.completedDays.contains(dateStr);
                final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateStr;

                return GestureDetector(
                  onTap: () {
                    context.read<HabitProvider>().toggleHabitDay(habit, dateStr);
                  },
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(day).substring(0, 1),
                        style: AppFontManager.bodySmall.copyWith(
                          fontSize: 10.sp,
                          color: isToday ? AppColors.primaryMedium : AppColors.textMuted,
                          fontWeight: isToday ? FontWeight.w900 : FontWeight.normal,
                        ),
                      ),
                      AppSpacing.h6,
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: isCompleted ? AppColors.primaryMedium : AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.primaryMedium
                                : (isToday ? AppColors.primaryLight : AppColors.divider),
                            width: isToday ? 2.2 : 1,
                          ),
                          boxShadow: isToday
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: isCompleted
                            ? Icon(Icons.check, color: AppColors.white, size: 16.sp)
                            : (isToday
                                ? Text(
                                    DateFormat('d').format(day),
                                    style: AppFontManager.bodySmall.copyWith(
                                      fontSize: 10.sp,
                                      color: AppColors.primaryMedium,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                : Icon(Icons.close_rounded,
                                    color: AppColors.divider.withValues(alpha: 0.8), size: 12.sp)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
