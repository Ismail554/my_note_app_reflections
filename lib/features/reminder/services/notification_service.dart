import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:Reflections/features/reminder/data/models/reminder_model.dart';
import 'package:Reflections/features/timer/presentation/providers/focus_timer_provider.dart';
import 'package:Reflections/core/utils/app_navigator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Timezone Database Init
    tz.initializeTimeZones();

    // 2. Android Settings
    const androidInitSettings =
        AndroidInitializationSettings('ic_notification');

    // 3. iOS/Darwin Settings
    final darwinInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          'focus_timer_category',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('pause', 'Pause'),
            DarwinNotificationAction.plain('resume', 'Resume'),
            DarwinNotificationAction.plain(
              'stop',
              'Stop',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
          ],
        ),
      ],
    );

    final initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );

    // 4. Plugin initialization
    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) async {
        final action = details.actionId;
        if (action != null) {
          final activeProvider = FocusTimerProvider.activeInstance;
          if (activeProvider != null) {
            if (action == 'pause') {
              activeProvider.pauseTimer();
            } else if (action == 'resume') {
              activeProvider.startTimer();
            } else if (action == 'stop') {
              activeProvider.resetTimer();
            }
          } else {
            timerNotificationTapBackground(details);
          }
        } else {
          // Tap on notification body
          final payload = details.payload;
          if (payload != null) {
            if (payload == 'focus_timer') {
              AppNavigator.goToFocusTimer();
            } else if (payload.startsWith('http://') || payload.startsWith('https://')) {
              final uri = Uri.tryParse(payload);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: timerNotificationTapBackground,
    );

    // Handle app launch from notification tap
    final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final response = launchDetails.notificationResponse;
      if (response != null) {
        final payload = response.payload;
        if (payload != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Future.delayed(const Duration(milliseconds: 500));
            if (payload == 'focus_timer') {
              AppNavigator.goToFocusTimer();
            } else if (payload.startsWith('http://') || payload.startsWith('https://')) {
              final uri = Uri.tryParse(payload);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          });
        }
      }
    }
  }

  Future<void> requestPermissions() async {
    // Android 13+ permission request
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

    // iOS Permission request
    final iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Schedule a precise alarm/reminder at target DateTime
  Future<void> scheduleNotification(ReminderModel reminder) async {
    if (reminder.triggerDateTime.isBefore(DateTime.now())) return;

    // Convert DateTime to Timezone TZDateTime
    final scheduledDate = tz.TZDateTime.from(reminder.triggerDateTime, tz.local);

    // Android details configuration
    final androidDetails = AndroidNotificationDetails(
      reminder.isAlarm ? 'reflections_alarms' : 'reflections_reminders',
      reminder.isAlarm ? 'Reflections Alarms' : 'Reflections Reminders',
      channelDescription: reminder.isAlarm
          ? 'Urgent timed alarms that demand attention'
          : 'Standard scheduled reminders',
      importance: reminder.isAlarm ? Importance.max : Importance.defaultImportance,
      priority: reminder.isAlarm ? Priority.high : Priority.defaultPriority,
      playSound: true,
      enableVibration: true,
      category: reminder.isAlarm ? AndroidNotificationCategory.alarm : AndroidNotificationCategory.reminder,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: reminder.notificationId,
      title: reminder.title,
      body: reminder.description,
      scheduledDate: scheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: _extractUrl(reminder.description) ?? _extractUrl(reminder.title),
    );
  }

  /// Extracts the first http/https URL from text
  String? _extractUrl(String? text) {
    if (text == null || text.isEmpty) return null;
    final RegExp urlRegExp = RegExp(
      r'https?://[a-zA-Z0-9\-._~:/?#\[\]@!$&()*+,;=%]+',
      caseSensitive: false,
    );
    final match = urlRegExp.firstMatch(text);
    return match?.group(0);
  }

  /// Cancels an active scheduled alarm
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  /// Quick notification for completed actions
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reflections_instant',
      'Reflections General',
      channelDescription: 'General instant notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    
    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: _extractUrl(body) ?? _extractUrl(title),
    );
  }
}
