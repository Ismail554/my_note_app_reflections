import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/features/todo/presentation/pages/todo_list_page.dart';
import 'package:Reflections/features/habit/presentation/pages/habit_tracker_page.dart';
import 'package:Reflections/features/reminder/presentation/pages/reminder_manager_page.dart';
import 'package:Reflections/features/analytics/presentation/pages/analytics_page.dart';

class TasksDashboardPage extends StatefulWidget {
  const TasksDashboardPage({super.key});

  @override
  State<TasksDashboardPage> createState() => _TasksDashboardPageState();
}

class _TasksDashboardPageState extends State<TasksDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: noteProvider.selectedTasksTabIndex.clamp(0, 3),
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        noteProvider.setSelectedTasksTabIndex(_tabController.index);
      }
    });

    noteProvider.addListener(_onNoteProviderChange);
  }

  void _onNoteProviderChange() {
    if (!mounted) return;
    final targetIndex = Provider.of<NoteProvider>(
      context,
      listen: false,
    ).selectedTasksTabIndex.clamp(0, 3);
    if (_tabController.index != targetIndex) {
      _tabController.animateTo(targetIndex);
    }
  }

  @override
  void dispose() {
    try {
      Provider.of<NoteProvider>(
        context,
        listen: false,
      ).removeListener(_onNoteProviderChange);
    } catch (_) {}
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            child: Text(
              'Tasks Hub',
              style: AppFontManager.displayMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ─── Tab Bar ────────────────────────────────────────────
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(11.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: AppColors.accent,
              unselectedLabelColor: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
              labelStyle: AppFontManager.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
              ),
              unselectedLabelStyle: AppFontManager.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'To-Do'),
                Tab(text: 'Habits'),
                Tab(text: 'Alarms'),
                Tab(text: 'Activity'),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // ─── Tab Views ──────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: const [
                TodoListPage(),
                HabitTrackerPage(),
                ReminderManagerPage(),
                AnalyticsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
