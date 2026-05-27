import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';

/// GitHub-style contribution heatmap widget.
/// Renders a scrollable grid of intensity-coded cells showing daily activity.
class HeatmapGrid extends StatelessWidget {
  /// Map of "YYYY-MM-DD" → count of completions on that day
  final Map<String, int> data;

  /// How many weeks to show (default 20 = ~5 months)
  final int weeks;

  const HeatmapGrid({
    super.key,
    required this.data,
    this.weeks = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final totalDays = weeks * 7;
    final startDate = today.subtract(Duration(days: totalDays - 1));

    // Find max for intensity scaling
    final maxCount = data.values.fold<int>(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels
        _MonthLabels(startDate: startDate, weeks: weeks, isDark: isDark),
        SizedBox(height: 4.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels (Mon, Wed, Fri)
            _DayLabels(isDark: isDark),
            SizedBox(width: 4.w),
            // Grid
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                child: _Grid(
                  startDate: startDate,
                  totalDays: totalDays,
                  weeks: weeks,
                  data: data,
                  maxCount: maxCount,
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // Legend
        _Legend(isDark: isDark),
      ],
    );
  }
}

class _MonthLabels extends StatelessWidget {
  final DateTime startDate;
  final int weeks;
  final bool isDark;

  const _MonthLabels({required this.startDate, required this.weeks, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // placeholder — month labels are part of the grid scroll
    return SizedBox(height: 14.h);
  }
}

class _DayLabels extends StatelessWidget {
  final bool isDark;
  const _DayLabels({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final labels = ['', 'M', '', 'W', '', 'F', ''];
    return Column(
      children: labels.map((label) {
        return SizedBox(
          height: 12.h,
          child: label.isNotEmpty
              ? Text(
                  label,
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
        );
      }).toList(),
    );
  }
}

class _Grid extends StatelessWidget {
  final DateTime startDate;
  final int totalDays;
  final int weeks;
  final Map<String, int> data;
  final int maxCount;
  final bool isDark;

  const _Grid({
    required this.startDate,
    required this.totalDays,
    required this.weeks,
    required this.data,
    required this.maxCount,
    required this.isDark,
  });

  int _getLevel(int count) {
    if (count == 0 || maxCount == 0) return 0;
    final ratio = count / maxCount;
    if (ratio <= 0.25) return 1;
    if (ratio <= 0.50) return 2;
    if (ratio <= 0.75) return 3;
    return 4;
  }

  Color _colorForLevel(int level) {
    if (isDark) {
      switch (level) {
        case 0: return AppColors.heatmap0;
        case 1: return AppColors.heatmap1;
        case 2: return AppColors.heatmap2;
        case 3: return AppColors.heatmap3;
        default: return AppColors.heatmap4;
      }
    } else {
      switch (level) {
        case 0: return AppColors.heatmap0Light;
        case 1: return AppColors.heatmap1Light;
        case 2: return AppColors.heatmap2Light;
        case 3: return AppColors.heatmap3Light;
        default: return AppColors.heatmap4Light;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = 10.r;
    final gap = 2.r;

    return SizedBox(
      height: 7 * (cellSize + gap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(weeks, (weekIndex) {
          return Column(
            children: List.generate(7, (dayIndex) {
              final dayOffset = weekIndex * 7 + dayIndex;
              if (dayOffset >= totalDays) {
                return SizedBox(width: cellSize + gap, height: cellSize + gap);
              }

              final date = startDate.add(Duration(days: dayOffset));
              final dateStr = date.toIso8601String().substring(0, 10);
              final count = data[dateStr] ?? 0;
              final level = _getLevel(count);

              return Container(
                width: cellSize,
                height: cellSize,
                margin: EdgeInsets.all(gap / 2),
                decoration: BoxDecoration(
                  color: _colorForLevel(level),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final bool isDark;
  const _Legend({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cellSize = 10.r;
    final colors = isDark
        ? [AppColors.heatmap0, AppColors.heatmap1, AppColors.heatmap2, AppColors.heatmap3, AppColors.heatmap4]
        : [AppColors.heatmap0Light, AppColors.heatmap1Light, AppColors.heatmap2Light, AppColors.heatmap3Light, AppColors.heatmap4Light];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: AppFontManager.caption.copyWith(
            fontSize: 8.sp,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        SizedBox(width: 4.w),
        ...colors.map((color) => Container(
              width: cellSize,
              height: cellSize,
              margin: EdgeInsets.only(right: 2.w),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2.r),
              ),
            )),
        SizedBox(width: 4.w),
        Text(
          'More',
          style: AppFontManager.caption.copyWith(
            fontSize: 8.sp,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ],
    );
  }
}
