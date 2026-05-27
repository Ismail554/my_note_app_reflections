import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/features/todo/presentation/pages/todo_list_page.dart';
import 'package:Reflections/features/habit/presentation/pages/habit_tracker_page.dart';
import 'package:Reflections/features/reminder/presentation/pages/reminder_manager_page.dart';

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
      length: 3,
      vsync: this,
      initialIndex: noteProvider.selectedTasksTabIndex,
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
    final targetIndex = Provider.of<NoteProvider>(context, listen: false).selectedTasksTabIndex;
    if (_tabController.index != targetIndex) {
      _tabController.animateTo(targetIndex);
    }
  }

  @override
  void dispose() {
    // Check if context is still valid or use a try-catch to avoid issues when disposing
    try {
      Provider.of<NoteProvider>(context, listen: false).removeListener(_onNoteProviderChange);
    } catch (_) {}
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Section ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tasks Hub',
                    style: AppFontManager.displayMedium,
                  ),
                  Text(
                    'Track checklists, daily check-ins, and timed alarms.',
                    style: AppFontManager.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // ─── Styled Custom Tab Bar ────────────────────────────────────
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppColors.primaryDark,
                unselectedLabelColor: AppColors.textMuted,
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
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // ─── Tab Views ────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: const [
                  TodoListPage(),
                  HabitTrackerPage(),
                  ReminderManagerPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
