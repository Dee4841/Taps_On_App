enum GoalFilter { all, today, thisWeek, overdue }

class Goal {
  final String id;
  final String userId;
  final String title;
  final DateTime? dueDate;
  final bool isComplete;
  final DateTime? createdAt;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.dueDate,
    this.isComplete = false,
    this.createdAt,
  });

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id']?.toString() ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      dueDate: map['due_date'] != null ? DateTime.tryParse(map['due_date']) : null,
      isComplete: map['is_complete'] ?? false,
    );
  }
}
