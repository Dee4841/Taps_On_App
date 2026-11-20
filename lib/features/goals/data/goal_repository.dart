import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/goal.dart';

class GoalRepository {
  final SupabaseClient _client;

  GoalRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<Goal>> getGoals(String userId) async {
    final response = await _client
        .from('goals')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((g) => Goal.fromMap(g)).toList();
  }

  Future<Goal> addGoal({
    required String userId,
    required String title,
    DateTime? dueDate,
  }) async {
    final response = await _client
        .from('goals')
        .insert({
          'user_id': userId,
          'title': title,
          'due_date': dueDate?.toIso8601String(),
        })
        .select()
        .single();
    return Goal.fromMap(response);
  }

  Future<void> toggleComplete(String goalId, bool currentStatus) async {
    await _client.from('goals').update({
      'is_complete': !currentStatus,
    }).eq('id', goalId);
  }

  Future<void> deleteGoal(String goalId) async {
    await _client.from('goals').delete().eq('id', goalId);
  }
}
