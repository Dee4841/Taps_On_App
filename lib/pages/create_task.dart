import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/task_model.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final supabase = Supabase.instance.client;
  List<Task> _tasks = [];
  bool _loading = true;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'Medium';
  String _selectedPriority = 'All';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _loading = true);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      var query = supabase
          .from('tasks')
          .select()
          .eq('user_id', user.id)
          .order('due_date', ascending: true);

      // Apply priority filter AFTER fetching
      final data = await query;

      final rawTasks = (data as List<dynamic>)
          .map((json) => Task.fromJson(json))
          .toList();

      final filteredTasks = _selectedPriority == 'All'
          ? rawTasks
          : rawTasks.where((task) => task.priority == _selectedPriority).toList();

      setState(() {
        _tasks = filteredTasks;
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleComplete(Task task) async {
    await supabase
        .from('tasks')
        .update({'is_completed': !task.isCompleted})
        .eq('id', task.id);
    _fetchTasks();
  }

  Future<void> _deleteTask(Task task) async {
    await supabase.from('tasks').delete().eq('id', task.id);
    _fetchTasks();
  }

  Future<void> _showCreateTaskDialog() async {
    _titleController.clear();
    _descController.clear();
    _dueDate = null;
    _priority = 'Medium';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Create New Task'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(_dueDate == null
                          ? 'Pick Due Date'
                          : 'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            _dueDate = picked;
                          });
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _priority,
                      items: ['Low', 'Medium', 'High']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => _priority = val);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Priority'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _dueDate != null) {
                    final user = supabase.auth.currentUser;
                    if (user == null) return;

                    try {
                      final inserted = await supabase.from('tasks').insert({
                        'user_id': user.id,
                        'title': _titleController.text,
                        'description': _descController.text,
                        'due_date': _dueDate!.toIso8601String(),
                        'priority': _priority,
                        'is_completed': false,
                      }).select().single();

                      final task = Task.fromJson(inserted);
                      setState(() {
                        _tasks.add(task);
                      });
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving task: $e')),
                        );
                      }
                    }
                  } else {
                    if (_dueDate == null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please pick a due date')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditTaskDialog(Task task) async {
    _titleController.text = task.title;
    _descController.text = task.description ?? '';
    _dueDate = task.dueDate;
    _priority = task.priority;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Task'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(_dueDate == null
                          ? 'Pick Due Date'
                          : 'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            _dueDate = picked;
                          });
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _priority,
                      items: ['Low', 'Medium', 'High']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => _priority = val);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Priority'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await _deleteTask(task);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _dueDate != null) {
                    try {
                      await supabase.from('tasks').update({
                        'title': _titleController.text,
                        'description': _descController.text,
                        'due_date': _dueDate!.toIso8601String(),
                        'priority': _priority,
                      }).eq('id', task.id);

                      if (context.mounted) {
                        Navigator.pop(context);
                        _fetchTasks();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating task: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    items: ['All', 'Low', 'Medium', 'High']
                        .map((priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedPriority = val;
                        });
                        _fetchTasks();
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Filter by Priority'),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchTasks,
                    child: _tasks.isEmpty
                        ? const Center(child: Text('No tasks found.\nTap + to add a new task.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              return Dismissible(
                                key: Key(task.id),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => _deleteTask(task),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (_) => _toggleComplete(task),
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Due: ${task.dueDate.toLocal().toString().split(' ')[0]} • Priority: ${task.priority}',
                                  ),
                                  onTap: () => _showEditTaskDialog(task),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
        tooltip: 'Create Task',
      ),
    );
  }
}
