import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String id;
  final String name;
  final String description;
  final List<String> completedDays; // List of YYYY-MM-DD strings
  final int streakCount;
  final String? lastCompletedDate; // YYYY-MM-DD string
  final String? alarmTime; // HH:MM format
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HabitModel({
    required this.id,
    required this.name,
    this.description = '',
    this.completedDays = const [],
    this.streakCount = 0,
    this.lastCompletedDate,
    this.alarmTime,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HabitModel.fromMap(Map<String, dynamic> map, String id) {
    final completedDaysRaw = map['completedDays'] as List<dynamic>? ?? [];
    return HabitModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      completedDays: completedDaysRaw.map((e) => e.toString()).toList(),
      streakCount: map['streakCount'] as int? ?? 0,
      lastCompletedDate: map['lastCompletedDate'] as String?,
      alarmTime: map['alarmTime'] as String?,
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
      'name': name,
      'description': description,
      'completedDays': completedDays,
      'streakCount': streakCount,
      'lastCompletedDate': lastCompletedDate,
      'alarmTime': alarmTime,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Toggles the completion of a specific date (YYYY-MM-DD)
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

  // Helper calculation for exact streak
  int _calculateStreak(List<String> days) {
    if (days.isEmpty) return 0;
    final sorted = List<String>.from(days)..sort((a, b) => b.compareTo(a));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int streak = 0;
    DateTime checkDate = today;
    
    final todayStr = today.toIso8601String().substring(0, 10);
    final yesterdayStr = today.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
    
    if (sorted.contains(todayStr)) {
      checkDate = today;
    } else if (sorted.contains(yesterdayStr)) {
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      return 0; // Streak broken
    }
    
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

  HabitModel copyWith({
    String? id,
    String? name,
    String? description,
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
