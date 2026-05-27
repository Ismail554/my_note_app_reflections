import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String title;
  final String description;
  final DateTime triggerDateTime;
  final bool isScheduled;
  final bool isAlarm; // Louder ringtone flag
  final int notificationId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReminderModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.triggerDateTime,
    this.isScheduled = true,
    this.isAlarm = false,
    required this.notificationId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map, String id) {
    return ReminderModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      triggerDateTime: map['triggerDateTime'] is Timestamp
          ? (map['triggerDateTime'] as Timestamp).toDate()
          : DateTime.now(),
      isScheduled: map['isScheduled'] as bool? ?? true,
      isAlarm: map['isAlarm'] as bool? ?? false,
      notificationId: map['notificationId'] as int? ?? 0,
      userId: map['userId'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'triggerDateTime': Timestamp.fromDate(triggerDateTime),
      'isScheduled': isScheduled,
      'isAlarm': isAlarm,
      'notificationId': notificationId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? triggerDateTime,
    bool? isScheduled,
    bool? isAlarm,
    int? notificationId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      triggerDateTime: triggerDateTime ?? this.triggerDateTime,
      isScheduled: isScheduled ?? this.isScheduled,
      isAlarm: isAlarm ?? this.isAlarm,
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
