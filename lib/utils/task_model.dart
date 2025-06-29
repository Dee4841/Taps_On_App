// task_model.dart

class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      priority: json['priority'],
      isCompleted: json['is_completed'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'priority': priority,
        'is_completed': isCompleted,
      };
}
