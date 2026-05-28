import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/features/reminder/data/models/reminder_model.dart';
import 'package:Reflections/features/reminder/state/reminder_provider.dart';
import 'package:Reflections/features/reminder/services/notification_service.dart';
import 'package:Reflections/shared/widgets/empty_state.dart';
import 'package:Reflections/shared/widgets/create_entity_sheets.dart';

class ReminderManagerPage extends StatefulWidget {
  const ReminderManagerPage({super.key});

  @override
  State<ReminderManagerPage> createState() => _ReminderManagerPageState();
}

class _ReminderManagerPageState extends State<ReminderManagerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ReminderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppColors.accent));
        }

        final active = provider.upcomingReminders;

        if (active.isEmpty) {
          return EmptyState(
            message: 'No scheduled reminders.',
            actionLabel: 'Schedule Reminder',
            onAction: () => CreateEntitySheets.showAddReminderSheet(context),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              ...active.map((r) => _buildReminderCard(context, r, isDark)),
              SizedBox(height: 80.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderCard(BuildContext context, ReminderModel reminder, bool isDark) {
    final diff = reminder.triggerDateTime.difference(DateTime.now());
    String timeLeft;
    if (diff.inDays > 0) {
      timeLeft = 'In ${diff.inDays}d';
    } else if (diff.inHours > 0) {
      timeLeft = 'In ${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      timeLeft = 'In ${diff.inMinutes}m';
    } else {
      timeLeft = 'Soon';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: reminder.isAlarm
                  ? AppColors.error.withValues(alpha: 0.12)
                  : AppColors.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              reminder.isAlarm ? Icons.alarm_rounded : Icons.notifications_active_rounded,
              color: reminder.isAlarm ? AppColors.error : AppColors.accent,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: AppFontManager.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  DateFormat('E, MMM d • hh:mm a').format(reminder.triggerDateTime),
                  style: AppFontManager.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (reminder.description.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    reminder.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontManager.caption.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Time left + delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeLeft,
                style: AppFontManager.caption.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  fontSize: 10.sp,
                ),
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: () => context.read<ReminderProvider>().deleteReminder(reminder),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppFontManager.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
