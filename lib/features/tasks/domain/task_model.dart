class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;

  const Task({
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
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: DateTime.parse(json['due_date'].toString()),
      priority: json['priority'] as String? ?? 'Medium',
      isCompleted: json['is_completed'] as bool? ?? false,
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

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
