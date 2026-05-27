import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Reflections/features/reminder/data/models/reminder_model.dart';
import 'package:Reflections/features/reminder/data/repositories/reminder_repository.dart';
import 'package:Reflections/features/reminder/services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderRepository _repository = ReminderRepository();
  List<ReminderModel> _reminders = [];
  bool _isLoading = false;

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;

  // ─── Computed Getters ──────────────────────────────────────────────────

  List<ReminderModel> get upcomingReminders =>
      _reminders.where((r) => !r.isPast).toList();

  List<ReminderModel> get todayReminders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _reminders.where((r) {
      return r.triggerDateTime.isAfter(today) &&
          r.triggerDateTime.isBefore(tomorrow);
    }).toList();
  }

  // ─── Load / Refresh ────────────────────────────────────────────────────

  Future<void> loadReminders() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _reminders = await _repository.getReminders();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async => await loadReminders();

  // ─── CRUD ──────────────────────────────────────────────────────────────

  Future<void> addReminder({
    required String title,
    String description = '',
    required DateTime triggerTime,
    bool isAlarm = false,
    String repeatType = 'none',
  }) async {
    final currentUid = _repository.uid;
    if (currentUid == null) return;

    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000000);

    final newReminder = ReminderModel(
      title: title.trim(),
      description: description.trim(),
      triggerDateTime: triggerTime,
      isScheduled: true,
      isAlarm: isAlarm,
      repeatType: repeatType,
      notificationId: notificationId,
      userId: currentUid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.addReminder(newReminder);
    await NotificationService.instance.scheduleNotification(newReminder);
    await loadReminders();
  }

  Future<void> deleteReminder(ReminderModel reminder) async {
    await NotificationService.instance.cancelNotification(reminder.notificationId);
    if (reminder.id != null) {
      await _repository.deleteReminder(reminder.id!);
    }
    await loadReminders();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _repository.updateReminder(reminder);
    await loadReminders();
  }
}
