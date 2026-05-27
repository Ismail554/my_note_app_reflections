import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/features/habit/state/habit_provider.dart';
import 'package:Reflections/features/habit/data/models/habit_model.dart';
import 'package:Reflections/features/habit/presentation/widgets/heatmap_grid.dart';

class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({super.key});

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  Map<String, int> _heatmapData = {};

  @override
  void initState() {
    super.initState();
    _loadHeatmap();
  }

  Future<void> _loadHeatmap() async {
    final data = await context.read<HabitProvider>().getHeatmapData(daysBack: 140);
    if (mounted) setState(() => _heatmapData = data);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<HabitProvider>();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    return RefreshIndicator(
      onRefresh: () async {
        await provider.refresh();
        await _loadHeatmap();
      },
      color: AppColors.accent,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // ─── Heatmap ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              child: HeatmapGrid(data: _heatmapData, weeks: 20),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),

          // ─── Stats Row ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  _MiniStat(
                    label: 'Streak',
                    value: '${provider.currentStreak}',
                    icon: '🔥',
                    isDark: isDark,
                  ),
                  SizedBox(width: 12.w),
                  _MiniStat(
                    label: 'Today',
                    value: '${provider.todayCompletedCount}/${provider.habits.length}',
                    icon: '✓',
                    isDark: isDark,
                  ),
                  SizedBox(width: 12.w),
                  _MiniStat(
                    label: 'Rate',
                    value: '${(provider.todayCompletionRate * 100).toInt()}%',
                    icon: '📊',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),

          // ─── Section Header ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Habits',
                    style: AppFontManager.headingMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddHabitSheet(context, isDark),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.add_rounded, color: AppColors.accent, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),

          // ─── Habit Cards ─────────────────────────────────
          if (provider.habits.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
                child: Text(
                  'No habits yet. Tap + to create your first habit!',
                  textAlign: TextAlign.center,
                  style: AppFontManager.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == provider.habits.length) {
                      return SizedBox(height: 20.h);
                    }
                    final habit = provider.habits[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _HabitCard(
                        habit: habit,
                        todayStr: todayStr,
                        isDark: isDark,
                        onToggle: () async {
                          await provider.toggleHabitDay(habit, todayStr);
                          await _loadHeatmap();
                        },
                        onDelete: () => provider.deleteHabit(habit.id!),
                      ),
                    );
                  },
                  childCount: provider.habits.length + 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context, bool isDark) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedIcon = '🎯';

    final icons = ['🎯', '💪', '📚', '🧘', '🏃', '💧', '🎨', '🎵', '✍️', '🌅', '💤', '🥗'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            20.h,
            20.w,
            MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Habit',
                style: AppFontManager.headingLarge.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              // Icon picker
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: icons.map((icon) {
                  final isSelected = selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedIcon = icon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                        borderRadius: BorderRadius.circular(12.r),
                        border: isSelected
                            ? Border.all(color: AppColors.accent, width: 1.5)
                            : null,
                      ),
                      child: Text(icon, style: TextStyle(fontSize: 20.sp)),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Habit name'),
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: descController,
                decoration: const InputDecoration(hintText: 'Description (optional)'),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    context.read<HabitProvider>().addHabit(
                          name: nameController.text,
                          description: descController.text,
                          icon: selectedIcon,
                        );
                    Navigator.pop(ctx);
                    _loadHeatmap();
                  },
                  child: const Text('Create Habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final bool isDark;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 4.h),
            Text(
              value,
              style: AppFontManager.headingMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16.sp,
              ),
            ),
            Text(
              label,
              style: AppFontManager.caption.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
class _HabitCard extends StatelessWidget {
  final HabitModel habit;
  final String todayStr;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _HabitCard({
    required this.habit,
    required this.todayStr,
    required this.isDark,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = habit.isCompletedOn(todayStr);

    // Week progress dots
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      return date.toIso8601String().substring(0, 10);
    });

    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(Icons.delete_rounded, color: AppColors.error, size: 22.sp),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Habit?'),
            content: Text('Remove "${habit.name}" permanently?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.accent.withValues(alpha: 0.08)
                : (isDark ? AppColors.darkCard : AppColors.lightCard),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDone
                  ? AppColors.accent.withValues(alpha: 0.3)
                  : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Text(habit.icon, style: TextStyle(fontSize: 28.sp)),
              SizedBox(width: 14.w),
              // Name + week dots
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: AppFontManager.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    // Week dots
                    Row(
                      children: weekDays.map((dayStr) {
                        final completed = habit.isCompletedOn(dayStr);
                        final isToday = dayStr == todayStr;
                        return Container(
                          width: 8.r,
                          height: 8.r,
                          margin: EdgeInsets.only(right: 4.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: completed
                                ? AppColors.accent
                                : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                            border: isToday
                                ? Border.all(color: AppColors.accent, width: 1.5)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Streak badge
              if (habit.streakCount > 0) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.streakFire.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '🔥 ${habit.streakCount}',
                    style: AppFontManager.caption.copyWith(
                      color: AppColors.streakFire,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
