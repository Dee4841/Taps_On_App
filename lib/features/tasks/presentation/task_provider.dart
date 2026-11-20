import 'package:flutter/foundation.dart';
import '../domain/task_model.dart';
import '../data/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedPriority = 'All';

  TaskProvider(this._repository);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedPriority => _selectedPriority;

  Future<void> setPriority(String priority) async {
    if (_selectedPriority == priority) return;
    _selectedPriority = priority;
    await fetchTasks();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getTasks(priority: _selectedPriority);
    _isLoading = false;

    if (result.isSuccess) {
      _tasks = result.dataOrNull ?? [];
    } else {
      _errorMessage = result.failureOrNull?.message;
    }
    notifyListeners();
  }

  Future<bool> addTask({
    required String title,
    String? description,
    required DateTime dueDate,
    required String priority,
  }) async {
    final result = await _repository.createTask(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );

    if (result.isSuccess) {
      final newTask = result.dataOrNull!;
      if (_selectedPriority == 'All' || _selectedPriority == priority) {
        _tasks.add(newTask);
        _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        notifyListeners();
      }
      return true;
    } else {
      _errorMessage = result.failureOrNull?.message ?? 'Failed to save task';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
  }) async {
    final result = await _repository.updateTask(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );

    if (result.isSuccess) {
      await fetchTasks();
      return true;
    } else {
      _errorMessage = result.failureOrNull?.message ?? 'Failed to update task';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleComplete(Task task) async {
    final updatedStatus = !task.isCompleted;
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task.copyWith(isCompleted: updatedStatus);
      notifyListeners();
    }

    final result = await _repository.updateTask(
      id: task.id,
      isCompleted: updatedStatus,
    );

    if (result.isFailure) {
      if (index != -1) {
        _tasks[index] = task;
        _errorMessage = result.failureOrNull?.message;
        notifyListeners();
      }
    }
  }

  Future<void> deleteTask(String id) async {
    final previousTasks = List<Task>.from(_tasks);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();

    final result = await _repository.deleteTask(id);
    if (result.isFailure) {
      _tasks = previousTasks;
      _errorMessage = result.failureOrNull?.message;
      notifyListeners();
    }
  }
}
