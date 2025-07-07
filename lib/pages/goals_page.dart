import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

enum GoalFilter { all, today, thisWeek, overdue }

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;

  final supabase = Supabase.instance.client;

  GoalFilter _selectedFilter = GoalFilter.all;

  Future<void> _addGoal() async {
    final user = supabase.auth.currentUser;
    if (user == null || _titleController.text.trim().isEmpty) return;

    await supabase.from('goals').insert({
      'user_id': user.id,
      'title': _titleController.text.trim(),
      'due_date': _selectedDate?.toIso8601String(),
    });

    _titleController.clear();
    _selectedDate = null;
    setState(() {});
  }

  Future<void> _toggleComplete(String goalId, bool currentStatus) async {
    await supabase.from('goals').update({
      'is_complete': !currentStatus,
    }).eq('id', goalId);

    setState(() {});
  }

  Future<void> _deleteGoal(String goalId) async {
    await supabase.from('goals').delete().eq('id', goalId);
    setState(() {});
  }

 Future<List<Map<String, dynamic>>> _fetchGoals() async {
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  final today = DateTime.now();
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));

  try {
    // First get all goals for the user
    var response = await supabase
        .from('goals')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    List<Map<String, dynamic>> allGoals = List<Map<String, dynamic>>.from(response);

    // Then filter locally
    return allGoals.where((goal) {
      if (goal['due_date'] == null) return _selectedFilter == GoalFilter.all;
      
      final dueDate = DateTime.parse(goal['due_date']);
      final isComplete = goal['is_complete'] ?? false;

      switch (_selectedFilter) {
        case GoalFilter.today:
          return dueDate.year == today.year &&
                 dueDate.month == today.month &&
                 dueDate.day == today.day;
        case GoalFilter.thisWeek:
          return dueDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                 dueDate.isBefore(endOfWeek.add(const Duration(days: 1)));
        case GoalFilter.overdue:
          return dueDate.isBefore(today) && !isComplete;
        case GoalFilter.all:
        default:
          return true;
      }
    }).toList();
  } catch (e) {
    debugPrint('Error fetching goals: $e');
    return [];
  }
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

  Widget _buildFilterButton(String label, GoalFilter filter) {
    final isSelected = _selectedFilter == filter;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      _buildFilterButton("All", GoalFilter.all),
      const SizedBox(width: 8),
      _buildFilterButton("Today", GoalFilter.today),
      const SizedBox(width: 8),
      _buildFilterButton("This Week", GoalFilter.thisWeek),
      const SizedBox(width: 8),
      _buildFilterButton("Overdue", GoalFilter.overdue),
    ],
  ),
),

            const SizedBox(height: 10),

            // Goals List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchGoals(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final goals = snapshot.data!;

                  if (goals.isEmpty) return const Center(child: Text("No goals yet."));

                  return ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      final isComplete = goal['is_complete'] == true;
                      return ListTile(
                        leading: Checkbox(
                          value: isComplete,
                          onChanged: (_) => _toggleComplete(goal['id'], isComplete),
                        ),
                        title: Text(
                          goal['title'],
                          style: TextStyle(
                            decoration: isComplete ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: goal['due_date'] != null
                            ? Text("Due: ${DateFormat.yMMMd().format(DateTime.parse(goal['due_date']))}")
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteGoal(goal['id']),
                        ),
                      );
                    },
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
