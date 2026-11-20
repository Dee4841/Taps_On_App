import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/tasks/domain/task_model.dart';
import '../features/tasks/presentation/task_provider.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'Medium';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
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
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Enter title' : null,
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
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p,
                                  style: TextStyle(
                                    color: p == 'High'
                                        ? Colors.red
                                        : p == 'Medium'
                                            ? Colors.orange
                                            : null,
                                  ),
                                ),
                              ))
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
                    final provider = context.read<TaskProvider>();
                    final success = await provider.addTask(
                      title: _titleController.text.trim(),
                      description: _descController.text.trim().isEmpty
                          ? null
                          : _descController.text.trim(),
                      dueDate: _dueDate!,
                      priority: _priority,
                    );

                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.errorMessage ?? 'Error saving task',
                            ),
                          ),
                        );
                      }
                    }
                  } else if (_dueDate == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please pick a due date')),
                    );
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
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Enter title' : null,
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
                  await context.read<TaskProvider>().deleteTask(task.id);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _dueDate != null) {
                    final provider = context.read<TaskProvider>();
                    final success = await provider.updateTask(
                      id: task.id,
                      title: _titleController.text.trim(),
                      description: _descController.text.trim().isEmpty
                          ? null
                          : _descController.text.trim(),
                      dueDate: _dueDate,
                      priority: _priority,
                    );

                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.errorMessage ?? 'Error updating task',
                            ),
                          ),
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
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: taskProvider.isLoading && tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: taskProvider.selectedPriority,
                    items: ['All', 'Low', 'Medium', 'High']
                        .map((priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        taskProvider.setPriority(val);
                      }
                    },
                    decoration:
                        const InputDecoration(labelText: 'Filter by Priority'),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: taskProvider.fetchTasks,
                    child: tasks.isEmpty
                        ? const Center(
                            child: Text(
                                'No tasks found.\nTap + to add a new task.'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return Dismissible(
                                key: Key(task.id),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) =>
                                    taskProvider.deleteTask(task.id),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (_) =>
                                        taskProvider.toggleComplete(task),
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'Due: ${task.dueDate.toLocal().toString().split(' ')[0]} • Priority: ',
                                        ),
                                        TextSpan(
                                          text: task.priority,
                                          style: TextStyle(
                                            color: task.priority == 'High'
                                                ? Colors.red
                                                : task.priority == 'Medium'
                                                    ? Colors.orange
                                                    : null,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
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
        tooltip: 'Create Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
