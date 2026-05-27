import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:Reflections/features/reminder/data/models/reminder_model.dart';

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
        AndroidInitializationSettings('launcher_icon');

    // 3. iOS/Darwin Settings
    const darwinInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );

    // 4. Plugin initialization
    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click action if needed
      },
    );
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
    );
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
    );
  }
}
