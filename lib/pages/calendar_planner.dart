import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/calendar/presentation/event_provider.dart';
import '../features/calendar/domain/calendar_event.dart';

class CalendarPlannerPage extends StatefulWidget {
  const CalendarPlannerPage({super.key});

  @override
  State<CalendarPlannerPage> createState() => _CalendarPlannerPageState();
}

class _CalendarPlannerPageState extends State<CalendarPlannerPage> {
  final List<String> _categories = [
    'Assignment',
    'Test',
    'Study Session',
    'Reminder',
  ];

  final Map<String, Color> _categoryColors = {
    'Assignment': Colors.red,
    'Test': Colors.purple,
    'Study Session': Colors.green,
    'Reminder': Colors.orange,
  };

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedFilterCategory;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<EventProvider>().loadEvents(userId);
      }
    });
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    String selectedCategory = _categories[0];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 6,
                              backgroundColor: _categoryColors[cat],
                            ),
                            const SizedBox(width: 8),
                            Text(cat),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final userId = context.read<AuthProvider>().currentUser?.id;
              if (title.isNotEmpty && userId != null && _selectedDay != null) {
                Navigator.pop(context);
                await context.read<EventProvider>().addEvent(
                      userId: userId,
                      title: title,
                      date: _selectedDay!,
                      category: selectedCategory,
                    );
              }
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(CalendarEvent event) {
    final titleController = TextEditingController(text: event.title);
    String selectedCategory = event.category;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: _categoryColors[cat],
                      ),
                      const SizedBox(width: 8),
                      Text(cat),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final newTitle = titleController.text.trim();
              final userId = context.read<AuthProvider>().currentUser?.id;
              if (newTitle.isNotEmpty && userId != null) {
                Navigator.pop(context);
                await context.read<EventProvider>().updateEvent(
                      userId: userId,
                      id: event.id,
                      title: newTitle,
                      category: selectedCategory,
                    );
              }
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final displayedEvents = eventProvider.getEventsForDay(
      _selectedDay ?? _focusedDay,
      _selectedFilterCategory,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar & Planner')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) => eventProvider.getEventsForDay(day),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String?>(
              value: _selectedFilterCategory,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Categories'),
                ),
                ..._categories.map(
                  (cat) => DropdownMenuItem<String?>(
                    value: cat,
                    child: Row(
                      children: [
                        CircleAvatar(
                            radius: 6, backgroundColor: _categoryColors[cat]),
                        const SizedBox(width: 8),
                        Text(cat),
                      ],
                    ),
                  ),
                )
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilterCategory = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: displayedEvents.map((e) {
                final color = _categoryColors[e.category] ?? Colors.grey;

                return Card(
                  color: color.withOpacity(0.1),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => _showEditEventDialog(e),
                    onLongPress: () async {
                      final authProvider = context.read<AuthProvider>();
                      final eventProvider = context.read<EventProvider>();
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Event'),
                          content: const Text(
                              'Are you sure you want to delete this event?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final userId = authProvider.currentUser?.id;
                        if (userId != null) {
                          await eventProvider.deleteEvent(
                              userId: userId, id: e.id);
                        }
                      }
                    },
                    leading: CircleAvatar(
                      radius: 6,
                      backgroundColor: color,
                    ),
                    title: Text(
                      e.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(e.category),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
