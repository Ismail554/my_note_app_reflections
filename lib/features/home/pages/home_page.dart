import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/core/services/firebase_messaging_service.dart';
import 'package:Reflections/core/utils/app_navigator.dart';
import 'package:Reflections/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:Reflections/features/home/presentation/widgets/notes_tab.dart';
import 'package:Reflections/features/home/presentation/widgets/today_dashboard.dart';
import 'package:Reflections/features/tasks/presentation/pages/tasks_dashboard_page.dart';
import 'package:Reflections/features/profile/presentation/pages/profile_page.dart';
import 'package:Reflections/features/habit/state/habit_provider.dart';
import 'package:Reflections/features/todo/state/todo_provider.dart';
import 'package:Reflections/features/reminder/state/reminder_provider.dart';
import 'package:Reflections/shared/widgets/create_entity_sheets.dart';
import 'package:Reflections/shared/widgets/bubble_fab.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/features/timer/presentation/pages/focus_timer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load SQLite data for habits/todos/reminders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
      context.read<TodoProvider>().loadTodos();
      context.read<ReminderProvider>().loadReminders();
      FirebaseMessagingService.checkAndHandlePendingNotification(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final index = noteProvider.selectedNavIndex;

    // 4 tab bodies — IndexedStack keeps state alive
    final List<Widget> tabs = [
      const TodayDashboard(),
      NotesTab(provider: noteProvider),
      const TasksDashboardPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: index, children: tabs),

          // Bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: HomeBottomNav(
              currentIndex: index,
              onTap: noteProvider.changeNavIndex,
            ),
          ),

          // Bubble FAB (Today, Notes, Tasks tabs)
          if (index >= 0 && index <= 2)
            Positioned(
              right: 16.w,
              bottom: 100.h,
              child: BubbleFab(items: _buildBubbleItems(context)),
            ),
        ],
      ),
    );
  }

  List<BubbleMenuItem> _buildBubbleItems(BuildContext context) {
    return [
      BubbleMenuItem(
        icon: Icons.note_add_rounded,
        label: 'New Note',
        color: AppColors.streakFire,
        onTap: () => AppNavigator.goToAddNote(),
      ),
      BubbleMenuItem(
        icon: Icons.add_task_rounded,
        label: 'New Task',
        color: AppColors.mediumGreen,
        onTap: () => CreateEntitySheets.showAddTaskSheet(context),
      ),
      BubbleMenuItem(
        icon: Icons.repeat_rounded,
        label: 'Track Habit',
        color: AppColors.priorityHigh,
        onTap: () => CreateEntitySheets.showAddHabitSheet(context),
      ),
      BubbleMenuItem(
        icon: Icons.alarm_add_rounded,
        label: 'Set Reminder',
        color: const Color(0xFF2980B9),
        onTap: () => CreateEntitySheets.showAddReminderSheet(context),
      ),
      BubbleMenuItem(
        icon: Icons.timer_outlined,
        label: 'Focus Timer',
        color: AppColors.accent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FocusTimerPage(),
          ),
        ),
      ),
    ];
  }
}
