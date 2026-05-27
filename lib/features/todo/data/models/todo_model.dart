class TodoModel {
  final int? id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String priority; // Low, Medium, High
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoModel({
    this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.completedAt,
    this.priority = 'Medium',
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // ─── SQLite ─────────────────────────────────────────────────────────────

  factory TodoModel.fromSqlite(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      dueDate: map['due_date'] != null
          ? DateTime.tryParse(map['due_date'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      priority: map['priority'] as String? ?? 'Medium',
      userId: map['user_id'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toSqlite() {
    final map = <String, dynamic>{
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'priority': priority,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // ─── JSON (for export/import) ───────────────────────────────────────────

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      priority: json['priority'] as String? ?? 'Medium',
      userId: json['userId'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  int get priorityWeight {
    switch (priority.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  // ─── Copy ───────────────────────────────────────────────────────────────

  TodoModel copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? completedAt,
    String? priority,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
