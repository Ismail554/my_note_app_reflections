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

class ReminderManagerPage extends StatefulWidget {
  const ReminderManagerPage({super.key});

  @override
  State<ReminderManagerPage> createState() => _ReminderManagerPageState();
}

class _ReminderManagerPageState extends State<ReminderManagerPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDateTime;
  bool _isAlarm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.requestPermissions();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showAddReminderSheet(BuildContext context) {
    _titleController.clear();
    _descController.clear();
    _selectedDateTime = null;
    _isAlarm = false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24.w, 24.h, 24.w,
                MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Reminder', style: AppFontManager.headingLarge.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  )),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Title (e.g. Daily Standup)'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(hintText: 'Description (optional)'),
                  ),
                  SizedBox(height: 16.h),

                  // Date & Time picker
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 18.sp, color: AppColors.accent),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _selectedDateTime == null
                              ? 'No time set'
                              : DateFormat('MMM d, y • hh:mm a').format(_selectedDateTime!),
                          style: AppFontManager.bodyMedium.copyWith(
                            color: _selectedDateTime == null
                                ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date == null || !ctx.mounted) return;
                          final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                          if (time == null) return;
                          setModalState(() {
                            _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          });
                        },
                        child: const Text('Set Time'),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Alarm toggle
                  Row(
                    children: [
                      Icon(
                        _isAlarm ? Icons.alarm_on_rounded : Icons.notifications_none_rounded,
                        size: 18.sp,
                        color: _isAlarm ? AppColors.error : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Treat as Alarm', style: AppFontManager.bodyMedium.copyWith(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w600,
                            )),
                            Text(
                              'High-importance looping alarm',
                              style: AppFontManager.caption.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(value: _isAlarm, onChanged: (v) => setModalState(() => _isAlarm = v)),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.trim().isEmpty || _selectedDateTime == null) return;
                        context.read<ReminderProvider>().addReminder(
                              title: _titleController.text,
                              description: _descController.text,
                              triggerTime: _selectedDateTime!,
                              isAlarm: _isAlarm,
                            );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Schedule'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
            onAction: () => _showAddReminderSheet(context),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddReminderSheet(context),
            tooltip: 'Add Reminder',
            child: Icon(Icons.alarm_add_rounded, size: 24.sp),
          ),
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
