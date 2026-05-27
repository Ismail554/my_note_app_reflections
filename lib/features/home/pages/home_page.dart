import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/features/activity/pages/archive_page.dart';
import 'package:Reflections/features/profile/presentation/pages/profile_page.dart';
import 'package:Reflections/features/search/pages/search_page.dart';
import 'package:Reflections/features/home/presentation/widgets/folder_drawer.dart';
import 'package:Reflections/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:Reflections/features/home/presentation/widgets/notes_tab.dart';
import 'package:Reflections/features/tasks/presentation/pages/tasks_dashboard_page.dart';
import 'package:Reflections/core/services/firebase_messaging_service.dart';
import 'package:Reflections/core/utils/app_navigator.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check and process any pending push notifications once HomePage is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseMessagingService.checkAndHandlePendingNotification(context);
    });

    final noteProvider = context.watch<NoteProvider>();
    final index = noteProvider.selectedNavIndex;

    // The 5 tab bodies — IndexedStack keeps state alive
    final List<Widget> tabs = [
      NotesTab(provider: noteProvider),
      const TasksDashboardPage(),
      const SearchPage(),
      const ArchivePage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const FolderDrawer(),
      body: Stack(
        children: [
          // Dynamic Tab Content
          IndexedStack(
            index: index,
            children: tabs,
          ),

          // Redesigned Frosted Glass Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: HomeBottomNav(
              currentIndex: index,
              onTap: noteProvider.changeNavIndex,
            ),
          ),

          // Floating Action Button (Only on Home Notes tab)
          if (index == 0)
            Positioned(
              right: 24.w,
              bottom: 106.h,
              child: FloatingActionButton(
                backgroundColor: AppColors.primaryMedium,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                onPressed: () => AppNavigator.goToAddNote(),
                tooltip: 'New Note',
                child: Icon(Icons.edit_rounded, size: 22.sp),
              ),
            ),
        ],
      ),
    );
  }
}
