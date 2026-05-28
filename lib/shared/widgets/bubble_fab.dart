import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';

/// Single bubble menu item config.
class BubbleMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const BubbleMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// Animated bubble popup FAB — items fan out vertically with stagger.
/// Premium replacement for bottom-sheet approach.
class BubbleFab extends StatefulWidget {
  final List<BubbleMenuItem> items;
  final bool visible;

  const BubbleFab({super.key, required this.items, this.visible = true});

  @override
  State<BubbleFab> createState() => _BubbleFabState();
}

class _BubbleFabState extends State<BubbleFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    if (_isOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _isOpen = !_isOpen);
  }

  void _close() {
    if (_isOpen) {
      _controller.reverse();
      setState(() => _isOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 220.w,
      height: (70.h * widget.items.length) + 60.h,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Bubble items — vertically stacked above FAB
          ...List.generate(widget.items.length, (i) {
            final item = widget.items[i];
            final reverseIndex = widget.items.length - 1 - i;

            final itemInterval = Interval(
              (reverseIndex * 0.08).clamp(0.0, 1.0),
              (0.5 + reverseIndex * 0.12).clamp(0.0, 1.0),
              curve: Curves.easeOutBack,
            );

            return AnimatedBuilder(
              animation: _controller,
              builder: (ctx, child) {
                final t = itemInterval.transform(_controller.value);
                final offsetY = (64.h * (i + 1)) * t;

                return Positioned(
                  bottom: 40.h + offsetY,
                  right: 6.w,
                  child: Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Transform.scale(scale: 0.4 + 0.6 * t, child: child),
                  ),
                );
              },
              child: _BubbleItem(
                item: item,
                isDark: isDark,
                onTap: () {
                  _close();
                  item.onTap();
                },
              ),
            );
          }),

          // Main FAB — rotates 45° to become ✕ when open
          Positioned(
            bottom: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (ctx, child) {
                return Transform.rotate(
                  angle: _controller.value * (pi / 4),
                  child: child,
                );
              },
              child: _MainFab(isDark: isDark, onTap: _toggle),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Main circular FAB with gradient
// ═══════════════════════════════════════════════════════════════════════════
class _MainFab extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _MainFab({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.r,
        height: 56.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.mediumGreen, AppColors.primaryGreen],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: AppColors.cream, size: 28.sp),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Individual bubble: label pill + colored icon circle
// ═══════════════════════════════════════════════════════════════════════════
class _BubbleItem extends StatelessWidget {
  final BubbleMenuItem item;
  final bool isDark;
  final VoidCallback onTap;

  const _BubbleItem({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.96)
                  : Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              item.label,
              style: AppFontManager.labelMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Icon circle
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.color.withValues(alpha: 0.15),
              border: Border.all(
                color: item.color.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(item.icon, color: item.color, size: 20.sp),
          ),
        ],
      ),
    );
  }
}
