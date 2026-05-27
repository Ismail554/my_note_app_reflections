import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/constants/app_constants.dart';
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
    // Request exact alarm permissions dynamically on first launch
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Alarm / Reminder', style: AppFontManager.headlineMedium),
                  AppSpacing.h16,

                  // Title Input
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    style: AppFontManager.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Title (e.g. Daily Standup, Drink Water)',
                      hintStyle: AppFontManager.bodyMedium.copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                    ),
                  ),
                  AppSpacing.h12,

                  // Description Input
                  TextField(
                    controller: _descController,
                    style: AppFontManager.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Description or Notes',
                      hintStyle: AppFontManager.bodyMedium.copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                    ),
                  ),
                  AppSpacing.h16,

                  // Date and Time picker launcher
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 18.sp, color: AppColors.primaryMedium),
                      AppSpacing.w8,
                      Text(
                        _selectedDateTime == null
                            ? 'No time set'
                            : DateFormat('MMM d, y • hh:mm a').format(_selectedDateTime!),
                        style: AppFontManager.bodyMedium.copyWith(
                          color: _selectedDateTime == null ? AppColors.textHint : AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date == null) return;
                          
                          if (context.mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time == null) return;

                            setModalState(() {
                              _selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        },
                        child: Text('Set Timing', style: AppFontManager.link),
                      ),
                    ],
                  ),
                  AppSpacing.h12,

                  // Alarm toggle
                  Row(
                    children: [
                      Icon(
                        _isAlarm ? Icons.alarm_on_rounded : Icons.notifications_none_rounded,
                        size: 18.sp,
                        color: _isAlarm ? Colors.red : AppColors.textMuted,
                      ),
                      AppSpacing.w8,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Treat as Alarm',
                            style: AppFontManager.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Triggers high-importance looping foreground alarms.',
                            style: AppFontManager.bodySmall.copyWith(fontSize: 10.sp),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Switch(
                        value: _isAlarm,
                        onChanged: (val) {
                          setModalState(() => _isAlarm = val);
                        },
                        activeThumbColor: Colors.red,
                        activeTrackColor: Colors.red.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  AppSpacing.h24,

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        if (_titleController.text.trim().isEmpty) return;
                        if (_selectedDateTime == null) return;

                        context.read<ReminderProvider>().addReminder(
                              _titleController.text,
                              _descController.text,
                              _selectedDateTime!,
                              _isAlarm,
                            );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Schedule Alarm',
                        style: AppFontManager.buttonLarge.copyWith(color: AppColors.white),
                      ),
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
    return Consumer<ReminderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryMedium));
        }

        // Filters out past reminders dynamically in UI
        final activeReminders = provider.reminders
            .where((r) => r.triggerDateTime.isAfter(DateTime.now()))
            .toList();

        if (activeReminders.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: EmptyState(
              message: 'No scheduled alarms or reminders.',
              actionLabel: 'Schedule Alarm',
              onAction: () => _showAddReminderSheet(context),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddReminderSheet(context),
            tooltip: 'Add Alarm',
            child: Icon(Icons.alarm_add_rounded, size: 24.sp),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              ...activeReminders.map((reminder) => _buildReminderCard(context, reminder)),
              AppSpacing.h80,
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderCard(BuildContext context, ReminderModel reminder) {
    final diff = reminder.triggerDateTime.difference(DateTime.now());
    String timeLeft = '';
    if (diff.inHours > 0) {
      timeLeft = 'In ${diff.inHours} hours';
    } else if (diff.inMinutes > 0) {
      timeLeft = 'In ${diff.inMinutes} mins';
    } else {
      timeLeft = 'Triggers soon';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          // Alarm Icon Action Indicator
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: reminder.isAlarm
                  ? Colors.red.withValues(alpha: 0.1)
                  : AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              reminder.isAlarm ? Icons.alarm_rounded : Icons.notifications_active_rounded,
              color: reminder.isAlarm ? Colors.red : AppColors.primaryDark,
              size: 20.sp,
            ),
          ),
          AppSpacing.w12,

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: AppFontManager.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  DateFormat('E, MMM d • hh:mm a').format(reminder.triggerDateTime),
                  style: AppFontManager.bodySmall.copyWith(
                    color: AppColors.primaryMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (reminder.description.isNotEmpty) ...[
                  AppSpacing.h2,
                  Text(
                    reminder.description,
                    style: AppFontManager.bodySmall.copyWith(fontSize: 10.sp),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.w12,

          // Remaining timer and action buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeLeft,
                style: AppFontManager.labelMedium.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10.sp,
                ),
              ),
              AppSpacing.h4,
              GestureDetector(
                onTap: () {
                  context.read<ReminderProvider>().deleteReminder(reminder);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppFontManager.labelMedium.copyWith(
                      color: AppColors.error,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
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
