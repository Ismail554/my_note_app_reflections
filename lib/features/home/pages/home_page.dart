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

          // FAB (only on Notes tab)
          if (index == 1)
            Positioned(
              right: 20.w,
              bottom: 80.h,
              child: FloatingActionButton(
                onPressed: () => AppNavigator.goToAddNote(),
                tooltip: 'New Note',
                child: Icon(Icons.add_rounded, size: 24.sp),
              ),
            ),
        ],
      ),
    );
  }
}
