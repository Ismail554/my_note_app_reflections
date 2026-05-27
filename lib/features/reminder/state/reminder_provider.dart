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

  ReminderProvider() {
    _initStream();
  }

  void _initStream() {
    if (FirebaseAuth.instance.currentUser == null) return;
    _isLoading = true;

    _repository.getRemindersStream().listen(
      (list) {
        _reminders = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addReminder(
    String title,
    String description,
    DateTime triggerTime,
    bool isAlarm,
  ) async {
    final uid = _repository.uid;
    if (uid == null) return;

    // Generate unique positive integer for local notification ID
    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000000);

    final newReminder = ReminderModel(
      id: '',
      title: title.trim(),
      description: description.trim(),
      triggerDateTime: triggerTime,
      isScheduled: true,
      isAlarm: isAlarm,
      notificationId: notificationId,
      userId: uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 1. Save to database
    await _repository.addReminder(newReminder);

    // 2. Register local alarm notification in background
    await NotificationService.instance.scheduleNotification(newReminder);
  }

  Future<void> deleteReminder(ReminderModel reminder) async {
    // 1. Cancel local alarm
    await NotificationService.instance.cancelNotification(reminder.notificationId);

    // 2. Remove from database
    await _repository.deleteReminder(reminder.id);
  }
}
