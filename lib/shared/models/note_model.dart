import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final String category;
  final bool isArchived;

  const NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.category = 'Reflections',
    this.isArchived = false,
  });

  /// Creates a note model from firestore
  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      userId: map['userId'] as String? ?? '',
      category: map['category'] as String? ?? 'Reflections',
      isArchived: map['isArchived'] as bool? ?? false,
    );
  }

  /// object to map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
      'category': category,
      'isArchived': isArchived,
    };
  }

  /// Returns a formatted date label like "Today", "Yesterday", or "Apr 18"
  String get dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
    // difference 
    final diff = today.difference(noteDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff == 2) return '2 days ago';
    if (diff == 3) return '3 days ago';
    if (diff == 4) return '4 days ago';
    if (diff == 5) return '5 days ago';
    if (diff == 6) return '6 days ago';
    if (diff == 7) return '1 week ago';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}';
  }

  /// Preview of description (first 120 characters)
  String get preview {
    if (description.isEmpty) return '';
    return description.length > 120
        ? '${description.substring(0, 120)}...'
        : description;
  }

    NoteModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? category,
    bool? isArchived,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
