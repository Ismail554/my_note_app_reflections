class HabitModel {
  final int? id;
  final String name;
  final String description;
  final String icon;
  final int color;
  final int targetDaysPerWeek;
  final List<String> completedDays; // YYYY-MM-DD strings
  final int streakCount;
  final String? lastCompletedDate;
  final String? alarmTime;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HabitModel({
    this.id,
    required this.name,
    this.description = '',
    this.icon = '🎯',
    this.color = 0xFFFF6B35,
    this.targetDaysPerWeek = 7,
    this.completedDays = const [],
    this.streakCount = 0,
    this.lastCompletedDate,
    this.alarmTime,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // ─── SQLite ─────────────────────────────────────────────────────────────

  /// Create from SQLite row (completedDays loaded separately)
  factory HabitModel.fromSqlite(Map<String, dynamic> map, {List<String> completedDays = const []}) {
    return HabitModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String? ?? '🎯',
      color: map['color'] as int? ?? 0xFFFF6B35,
      targetDaysPerWeek: map['target_days_per_week'] as int? ?? 7,
      completedDays: completedDays,
      alarmTime: map['alarm_time'] as String?,
      userId: map['user_id'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Convert to SQLite row (completedDays stored in separate table)
  Map<String, dynamic> toSqlite() {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'target_days_per_week': targetDaysPerWeek,
      'alarm_time': alarmTime,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // ─── JSON (for export/import) ───────────────────────────────────────────

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['completedDays'] as List<dynamic>? ?? [];
    return HabitModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🎯',
      color: json['color'] as int? ?? 0xFFFF6B35,
      targetDaysPerWeek: json['targetDaysPerWeek'] as int? ?? 7,
      completedDays: rawDays.map((e) => e.toString()).toList(),
      alarmTime: json['alarmTime'] as String?,
      userId: json['userId'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'targetDaysPerWeek': targetDaysPerWeek,
      'completedDays': completedDays,
      'alarmTime': alarmTime,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ─── Business Logic ─────────────────────────────────────────────────────

  HabitModel toggleDay(String dateStr) {
    final updatedDays = List<String>.from(completedDays);
    if (updatedDays.contains(dateStr)) {
      updatedDays.remove(dateStr);
    } else {
      updatedDays.add(dateStr);
    }

    final newStreak = _calculateStreak(updatedDays);
    final lastComp = updatedDays.isEmpty
        ? null
        : (List<String>.from(updatedDays)..sort()).last;

    return copyWith(
      completedDays: updatedDays,
      streakCount: newStreak,
      lastCompletedDate: lastComp,
      updatedAt: DateTime.now(),
    );
  }

  bool isCompletedOn(String dateStr) => completedDays.contains(dateStr);

  String get todayStr => DateTime.now().toIso8601String().substring(0, 10);
  bool get isCompletedToday => completedDays.contains(todayStr);

  double get weeklyCompletionRate {
    if (targetDaysPerWeek <= 0) return 0;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final dayStr = weekStart.add(Duration(days: i)).toIso8601String().substring(0, 10);
      if (completedDays.contains(dayStr)) count++;
    }
    return count / targetDaysPerWeek;
  }

  int _calculateStreak(List<String> days) {
    if (days.isEmpty) return 0;
    final sorted = List<String>.from(days)..sort((a, b) => b.compareTo(a));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayStr = today.toIso8601String().substring(0, 10);
    final yesterdayStr = today.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);

    DateTime checkDate;
    if (sorted.contains(todayStr)) {
      checkDate = today;
    } else if (sorted.contains(yesterdayStr)) {
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    int streak = 0;
    while (true) {
      final checkStr = checkDate.toIso8601String().substring(0, 10);
      if (sorted.contains(checkStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // ─── Copy ───────────────────────────────────────────────────────────────

  HabitModel copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    int? color,
    int? targetDaysPerWeek,
    List<String>? completedDays,
    int? streakCount,
    String? lastCompletedDate,
    String? alarmTime,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
      completedDays: completedDays ?? this.completedDays,
      streakCount: streakCount ?? this.streakCount,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      alarmTime: alarmTime ?? this.alarmTime,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
