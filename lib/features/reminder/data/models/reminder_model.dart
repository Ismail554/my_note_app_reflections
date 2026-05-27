class ReminderModel {
  final int? id;
  final String title;
  final String description;
  final DateTime triggerDateTime;
  final bool isScheduled;
  final bool isAlarm;
  final String repeatType; // none, daily, weekly, monthly
  final int notificationId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReminderModel({
    this.id,
    required this.title,
    this.description = '',
    required this.triggerDateTime,
    this.isScheduled = true,
    this.isAlarm = false,
    this.repeatType = 'none',
    required this.notificationId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // ─── SQLite ─────────────────────────────────────────────────────────────

  factory ReminderModel.fromSqlite(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      triggerDateTime: DateTime.tryParse(map['trigger_date_time'] as String? ?? '') ?? DateTime.now(),
      isScheduled: (map['is_scheduled'] as int? ?? 1) == 1,
      isAlarm: (map['is_alarm'] as int? ?? 0) == 1,
      repeatType: map['repeat_type'] as String? ?? 'none',
      notificationId: map['notification_id'] as int? ?? 0,
      userId: map['user_id'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toSqlite() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'trigger_date_time': triggerDateTime.toIso8601String(),
      'is_scheduled': isScheduled ? 1 : 0,
      'is_alarm': isAlarm ? 1 : 0,
      'repeat_type': repeatType,
      'notification_id': notificationId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // ─── JSON (for export/import) ───────────────────────────────────────────

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      triggerDateTime: DateTime.tryParse(json['triggerDateTime'] as String? ?? '') ?? DateTime.now(),
      isScheduled: json['isScheduled'] as bool? ?? true,
      isAlarm: json['isAlarm'] as bool? ?? false,
      repeatType: json['repeatType'] as String? ?? 'none',
      notificationId: json['notificationId'] as int? ?? 0,
      userId: json['userId'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'triggerDateTime': triggerDateTime.toIso8601String(),
      'isScheduled': isScheduled,
      'isAlarm': isAlarm,
      'repeatType': repeatType,
      'notificationId': notificationId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  bool get isPast => triggerDateTime.isBefore(DateTime.now());
  bool get isRepeating => repeatType != 'none';

  // ─── Copy ───────────────────────────────────────────────────────────────

  ReminderModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? triggerDateTime,
    bool? isScheduled,
    bool? isAlarm,
    String? repeatType,
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
      repeatType: repeatType ?? this.repeatType,
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
