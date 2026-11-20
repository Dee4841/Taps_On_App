import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/goals/domain/goal.dart';
import '../features/goals/presentation/goal_provider.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<GoalProvider>().loadGoals(userId);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addGoal() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    final title = _titleController.text.trim();
    if (userId == null || title.isEmpty) return;

    await context.read<GoalProvider>().addGoal(
          userId: userId,
          title: title,
          dueDate: _selectedDate,
        );

    _titleController.clear();
    setState(() {
      _selectedDate = null;
    });
  }

  Future<void> _toggleComplete(String goalId, bool currentStatus) async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    await context.read<GoalProvider>().toggleComplete(
          userId: userId,
          goalId: goalId,
          currentStatus: currentStatus,
        );
  }

  Future<void> _deleteGoal(String goalId) async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    await context.read<GoalProvider>().deleteGoal(
          userId: userId,
          goalId: goalId,
        );
  }

  void _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildFilterButton(
      BuildContext context, String label, GoalFilter filter, GoalFilter currentFilter) {
    final isSelected = currentFilter == filter;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: () {
        context.read<GoalProvider>().setFilter(filter);
      },
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final currentFilter = goalProvider.filter;
    final goals = goalProvider.filteredGoals;

    return Scaffold(
      appBar: AppBar(title: const Text("Goals")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Goal Form
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your goal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _pickDueDate,
                ),
                ElevatedButton(
                  onPressed: _addGoal,
                  child: const Text("Add"),
                ),
              ],
            ),
            if (_selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Due: ${DateFormat.yMMMd().format(_selectedDate!)}"),
              ),

            const SizedBox(height: 20),

            // Filter Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton(context, "All", GoalFilter.all, currentFilter),
                  const SizedBox(width: 8),
                  _buildFilterButton(context, "Today", GoalFilter.today, currentFilter),
                  const SizedBox(width: 8),
                  _buildFilterButton(context, "This Week", GoalFilter.thisWeek, currentFilter),
                  const SizedBox(width: 8),
                  _buildFilterButton(context, "Overdue", GoalFilter.overdue, currentFilter),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Goals List
            Expanded(
              child: goalProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : goals.isEmpty
                      ? const Center(child: Text("No goals yet."))
                      : ListView.builder(
                          itemCount: goals.length,
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            final isComplete = goal.isComplete;
                            return ListTile(
                              leading: Checkbox(
                                value: isComplete,
                                onChanged: (_) =>
                                    _toggleComplete(goal.id, isComplete),
                              ),
                              title: Text(
                                goal.title,
                                style: TextStyle(
                                  decoration:
                                      isComplete ? TextDecoration.lineThrough : null,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: goal.dueDate != null
                                  ? Text(
                                      "Due: ${DateFormat.yMMMd().format(goal.dueDate!)}")
                                  : null,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteGoal(goal.id),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
