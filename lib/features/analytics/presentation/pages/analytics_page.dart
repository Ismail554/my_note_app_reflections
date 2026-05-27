import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/features/analytics/state/analytics_provider.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AnalyticsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  // ─── Range Selector ─────────────────────────
                  _RangeSelector(
                    current: provider.range,
                    onChanged: provider.setRange,
                    isDark: isDark,
                  ),
                  SizedBox(height: 20.h),

                  // ─── Summary Cards ─────────────────────────
                  Row(
                    children: [
                      _SummaryCard(value: '${provider.totalHabitCompletions}', label: 'Habits Done', isDark: isDark),
                      SizedBox(width: 10.w),
                      _SummaryCard(value: '${provider.totalTodoCompletions}', label: 'Tasks Done', isDark: isDark),
                      SizedBox(width: 10.w),
                      _SummaryCard(value: '${provider.consistencyScore.toInt()}%', label: 'Consistency', isDark: isDark),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // ─── Habits Bar Chart ──────────────────────
                  Text('Habit Completions', style: AppFontManager.headingMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  )),
                  SizedBox(height: 12.h),
                  _ActivityBarChart(data: provider.habitData, color: AppColors.accent, isDark: isDark),
                  SizedBox(height: 24.h),

                  // ─── Todos Bar Chart ───────────────────────
                  Text('Task Completions', style: AppFontManager.headingMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  )),
                  SizedBox(height: 12.h),
                  _ActivityBarChart(data: provider.todoData, color: AppColors.success, isDark: isDark),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
class _RangeSelector extends StatelessWidget {
  final AnalyticsRange current;
  final ValueChanged<AnalyticsRange> onChanged;
  final bool isDark;

  const _RangeSelector({required this.current, required this.onChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: AnalyticsRange.values.map((r) {
          final isSelected = current == r;
          final label = r == AnalyticsRange.daily ? '7 Days' : r == AnalyticsRange.weekly ? '4 Weeks' : '6 Months';

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.darkCard : AppColors.lightCard)
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppFontManager.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.accent
                        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _SummaryCard({required this.value, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppFontManager.headingLarge.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppFontManager.caption.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
class _ActivityBarChart extends StatelessWidget {
  final Map<String, int> data;
  final Color color;
  final bool isDark;

  const _ActivityBarChart({required this.data, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 160.h,
        alignment: Alignment.center,
        child: Text(
          'No data yet',
          style: AppFontManager.bodySmall.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      );
    }

    final sortedKeys = data.keys.toList()..sort();
    final maxVal = data.values.fold<int>(1, (a, b) => a > b ? a : b).toDouble();
    final barWidth = (sortedKeys.length <= 7) ? 24.0 : 14.0;

    return Container(
      height: 180.h,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          width: 0.5,
        ),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxVal + 1,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == maxVal) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sortedKeys.length) return const SizedBox.shrink();

                  // Show every Nth label to avoid crowding
                  final showEvery = sortedKeys.length <= 7 ? 1 : (sortedKeys.length ~/ 7).clamp(1, 5);
                  if (idx % showEvery != 0) return const SizedBox.shrink();

                  final dateStr = sortedKeys[idx];
                  final date = DateTime.tryParse(dateStr);
                  final label = date != null ? DateFormat('d').format(date) : '';

                  return Text(
                    label,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                strokeWidth: 0.5,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(sortedKeys.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (data[sortedKeys[index]] ?? 0).toDouble(),
                  color: color,
                  width: barWidth,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
