import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/error/failure.dart';
import '../domain/task_model.dart';

class TaskRepository {
  final SupabaseClient _client;

  TaskRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<Result<List<Task>>> getTasks({String? priority}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Error(AuthFailure('User not authenticated.'));
    }

    try {
      var query = _client.from('tasks').select().eq('user_id', user.id);

      // Server-side filter directly on Postgres
      if (priority != null && priority != 'All') {
        query = query.eq('priority', priority);
      }

      final data = await query.order('due_date', ascending: true);
      final tasks =
          (data as List<dynamic>).map((e) => Task.fromJson(e)).toList();

      return Success(tasks);
    } catch (e) {
      return Error(UnknownFailure('Failed to load tasks: $e'));
    }
  }

  Future<Result<Task>> createTask({
    required String title,
    String? description,
    required DateTime dueDate,
    required String priority,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Error(AuthFailure('User not authenticated.'));
    }

    try {
      final data = await _client.from('tasks').insert({
        'user_id': user.id,
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'priority': priority,
        'is_completed': false,
      }).select().single();

      return Success(Task.fromJson(data));
    } catch (e) {
      return Error(UnknownFailure('Failed to create task: $e'));
    }
  }

  Future<Result<void>> updateTask({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (dueDate != null) updates['due_date'] = dueDate.toIso8601String();
      if (priority != null) updates['priority'] = priority;
      if (isCompleted != null) updates['is_completed'] = isCompleted;

      if (updates.isEmpty) return const Success(null);

      await _client.from('tasks').update(updates).eq('id', id);
      return const Success(null);
    } catch (e) {
      return Error(UnknownFailure('Failed to update task: $e'));
    }
  }

  Future<Result<void>> deleteTask(String id) async {
    try {
      await _client.from('tasks').delete().eq('id', id);
      return const Success(null);
    } catch (e) {
      return Error(UnknownFailure('Failed to delete task: $e'));
    }
  }
}
