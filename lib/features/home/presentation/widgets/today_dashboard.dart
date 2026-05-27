import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/features/habit/state/habit_provider.dart';
import 'package:Reflections/features/todo/state/todo_provider.dart';
import 'package:Reflections/features/reminder/state/reminder_provider.dart';
import 'package:intl/intl.dart';

class TodayDashboard extends StatelessWidget {
  const TodayDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 16.h)),
          // ─── Greeting ──────────────────────────────────────
          SliverToBoxAdapter(child: _GreetingHeader(isDark: isDark)),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          // ─── Streak + Stats Row ────────────────────────────
          SliverToBoxAdapter(child: _StatsRow(isDark: isDark)),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          // ─── Today's Habits ────────────────────────────────
          SliverToBoxAdapter(child: _TodayHabitsSection(isDark: isDark)),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          // ─── Today's Tasks ─────────────────────────────────
          SliverToBoxAdapter(child: _TodayTasksSection(isDark: isDark)),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          // ─── Upcoming Reminders ────────────────────────────
          SliverToBoxAdapter(child: _UpcomingRemindersSection(isDark: isDark)),
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  GREETING HEADER
// ═══════════════════════════════════════════════════════════════════════════
class _GreetingHeader extends StatelessWidget {
  final bool isDark;
  const _GreetingHeader({required this.isDark});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM d').format(now);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting,
            style: AppFontManager.displayLarge.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            dateStr,
            style: AppFontManager.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  STATS ROW (Streak + Habits Done + Tasks Done)
// ═══════════════════════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  final bool isDark;
  const _StatsRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final todoProvider = context.watch<TodoProvider>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _StatCard(
            icon: '🔥',
            value: '${habitProvider.currentStreak}',
            label: 'DAY STREAK',
            isDark: isDark,
          ),
          SizedBox(width: 12.w),
          _StatCard(
            icon: '🎯',
            value: '${habitProvider.todayCompletedCount}/${habitProvider.habits.length}',
            label: 'HABITS',
            isDark: isDark,
          ),
          SizedBox(width: 12.w),
          _StatCard(
            icon: '✅',
            value: '${todoProvider.completedCount}/${todoProvider.todos.length}',
            label: 'TASKS',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 20.sp)),
            SizedBox(height: 8.h),
            Text(
              value,
              style: AppFontManager.headingMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppFontManager.statLabel.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  TODAY'S HABITS
// ═══════════════════════════════════════════════════════════════════════════
class _TodayHabitsSection extends StatelessWidget {
  final bool isDark;
  const _TodayHabitsSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final habits = habitProvider.todayHabits;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Today\'s Habits',
            style: AppFontManager.headingMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (habits.isEmpty)
          _EmptyCard(message: 'No habits yet. Add one to start tracking!', isDark: isDark)
        else
          SizedBox(
            height: 80.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: habits.length,
              separatorBuilder: (context, index) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final habit = habits[index];
                final isDone = habit.isCompletedOn(todayStr);

                return GestureDetector(
                  onTap: () => habitProvider.toggleHabitDay(habit, todayStr),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 80.w,
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : (isDark ? AppColors.darkCard : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDone
                            ? AppColors.accent.withValues(alpha: 0.4)
                            : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                        width: isDone ? 1.5 : 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(habit.icon, style: TextStyle(fontSize: 24.sp)),
                        SizedBox(height: 4.h),
                        Text(
                          habit.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppFontManager.caption.copyWith(
                            color: isDone
                                ? AppColors.accent
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  TODAY'S TASKS
// ═══════════════════════════════════════════════════════════════════════════
class _TodayTasksSection extends StatelessWidget {
  final bool isDark;
  const _TodayTasksSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final tasks = todoProvider.todayTodos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Today\'s Tasks',
            style: AppFontManager.headingMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (tasks.isEmpty)
          _EmptyCard(message: 'All clear! No tasks for today.', isDark: isDark)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: tasks.length > 5 ? 5 : tasks.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _TodoCard(todo: task, isDark: isDark);
            },
          ),
      ],
    );
  }
}

class _TodoCard extends StatelessWidget {
  final dynamic todo;
  final bool isDark;
  const _TodoCard({required this.todo, required this.isDark});

  Color get _priorityColor {
    switch (todo.priority.toString().toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.priorityMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = context.read<TodoProvider>();

    return GestureDetector(
      onTap: () => todoProvider.toggleTodoStatus(todo),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
            Container(
              width: 3.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: _priorityColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                todo.title,
                style: AppFontManager.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              todo.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: todo.isCompleted
                  ? AppColors.success
                  : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  UPCOMING REMINDERS
// ═══════════════════════════════════════════════════════════════════════════
class _UpcomingRemindersSection extends StatelessWidget {
  final bool isDark;
  const _UpcomingRemindersSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();
    final upcoming = reminderProvider.upcomingReminders;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Upcoming Reminders',
            style: AppFontManager.headingMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (upcoming.isEmpty)
          _EmptyCard(message: 'No upcoming reminders.', isDark: isDark)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: upcoming.length > 3 ? 3 : upcoming.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final reminder = upcoming[index];
              final timeStr = DateFormat('MMM d, h:mm a').format(reminder.triggerDateTime);

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                    Icon(
                      reminder.isAlarm ? Icons.alarm_rounded : Icons.notifications_none_rounded,
                      color: AppColors.accent,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: AppFontManager.bodyMedium.copyWith(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            timeStr,
                            style: AppFontManager.caption.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  EMPTY STATE CARD
// ═══════════════════════════════════════════════════════════════════════════
class _EmptyCard extends StatelessWidget {
  final String message;
  final bool isDark;
  const _EmptyCard({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppFontManager.bodySmall.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ),
    );
  }
}
