import 'package:flutter/foundation.dart';
import '../data/goal_repository.dart';
import '../domain/goal.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository _goalRepository;

  GoalProvider({required GoalRepository goalRepository})
      : _goalRepository = goalRepository;

  List<Goal> _goals = [];
  GoalFilter _filter = GoalFilter.all;
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  GoalFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Goal> get filteredGoals {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _goals.where((goal) {
      if (goal.dueDate == null) return _filter == GoalFilter.all;
      final dueDate = goal.dueDate!;

      switch (_filter) {
        case GoalFilter.today:
          return dueDate.year == today.year &&
              dueDate.month == today.month &&
              dueDate.day == today.day;
        case GoalFilter.thisWeek:
          return dueDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              dueDate.isBefore(endOfWeek.add(const Duration(days: 1)));
        case GoalFilter.overdue:
          return dueDate.isBefore(today) && !goal.isComplete;
        case GoalFilter.all:
          return true;
      }
    }).toList();
  }

  void setFilter(GoalFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  Future<void> loadGoals(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _goalRepository.getGoals(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal({
    required String userId,
    required String title,
    DateTime? dueDate,
  }) async {
    await _goalRepository.addGoal(
      userId: userId,
      title: title,
      dueDate: dueDate,
    );
    await loadGoals(userId);
  }

  Future<void> toggleComplete({
    required String userId,
    required String goalId,
    required bool currentStatus,
  }) async {
    await _goalRepository.toggleComplete(goalId, currentStatus);
    await loadGoals(userId);
  }

  Future<void> deleteGoal({required String userId, required String goalId}) async {
    await _goalRepository.deleteGoal(goalId);
    await loadGoals(userId);
  }
}
