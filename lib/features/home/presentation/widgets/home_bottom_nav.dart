import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          BottomNavigationBarItem(
            icon: NavIcon(
              icon: Icons.home_outlined,
              isSelected: currentIndex == 0,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: NavIcon(
              icon: Icons.search_rounded,
              isSelected: currentIndex == 1,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: NavIcon(
              icon: Icons.archive_outlined,
              isSelected: currentIndex == 2,
            ),
            label: 'Archive',
          ),
          BottomNavigationBarItem(
            icon: NavIcon(
              icon: Icons.settings_outlined,
              isSelected: currentIndex == 3,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const NavIcon({super.key, required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(isSelected ? 6.r : 4.r),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        icon,
        color: isSelected ? AppColors.primaryDark : AppColors.textHint,
        size: 22.sp,
      ),
    );
  }
}
