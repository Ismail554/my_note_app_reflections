import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/features/activity/pages/archive_page.dart';
import 'package:Reflections/features/home/presentation/controller/home_controller.dart';
import 'package:Reflections/features/profile/presentation/pages/profile_page.dart';
import 'package:Reflections/features/search/pages/search_page.dart';
import 'package:Reflections/features/home/presentation/widgets/folder_drawer.dart';
import 'package:Reflections/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:Reflections/features/home/presentation/widgets/notes_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    // The 4 tab bodies — IndexedStack keeps state alive
    final List<Widget> tabs = [
      NotesTab(controller: controller),
      const SearchPage(),
      const ArchivePage(),
      const SettingsPage(),
    ];

    return Obx(() {
      final index = controller.selectedNavIndex.value;
      return Scaffold(
        backgroundColor: AppColors.background,
        drawer: FolderDrawer(controller: controller),
        body: IndexedStack(index: index, children: tabs),

        // ─── FAB (only on Home tab) ────────────────────────────────────
        floatingActionButton: index == 0
            ? FloatingActionButton(
                onPressed: controller.navigateToAddNote,
                tooltip: 'New Note',
                child: Icon(Icons.edit_rounded, size: 22.r),
              )
            : null,

        // ─── Bottom Nav ────────────────────────────────────────────────
        bottomNavigationBar: HomeBottomNav(
          currentIndex: index,
          onTap: controller.changeNavIndex,
        ),
      );
    });
  }
}
