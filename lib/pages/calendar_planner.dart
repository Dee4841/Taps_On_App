import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/calender_event.dart';

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

  final SupabaseClient _client = Supabase.instance.client;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CalendarEvent>> _eventsByDate = {};
  String? _selectedFilterCategory; // null means show all

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _addEventToSupabase(String title, String category) async {
    final user = _client.auth.currentUser;
    if (user == null || _selectedDay == null) return;

    final newEvent = {
      'user_id': user.id,
      'title': title,
      'date': _selectedDay!.toIso8601String(),
      'category': category,
    };

    await _client.from('events').insert(newEvent);
    await _loadEvents();
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
              if (title.isNotEmpty) {
                Navigator.pop(context);
                await _addEventToSupabase(title, selectedCategory);
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

  Future<void> _loadEvents() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final data = await _client.from('events').select().eq('user_id', user.id);

    final allEvents =
        data.map<CalendarEvent>((e) => CalendarEvent.fromMap(e)).toList();

    setState(() {
      _eventsByDate.clear();
      for (final event in allEvents) {
        final dayKey =
            DateTime(event.date.year, event.date.month, event.date.day);
        _eventsByDate.putIfAbsent(dayKey, () => []).add(event);
      }
    });
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final events = _eventsByDate[key] ?? [];

    if (_selectedFilterCategory == null) return events;
    return events
        .where((e) => e.category == _selectedFilterCategory)
        .toList();
  }

  Future<void> _deleteEvent(String eventId) async {
    await _client.from('events').delete().eq('id', eventId);
    await _loadEvents();
  }

  Future<void> _editEvent(
      String eventId, String newTitle, String newCategory) async {
    await _client.from('events').update({
      'title': newTitle,
      'category': newCategory,
    }).eq('id', eventId);
    await _loadEvents();
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
              if (newTitle.isNotEmpty) {
                Navigator.pop(context);
                await _editEvent(event.id, newTitle, selectedCategory);
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
      color: Colors.black, // Customize dot color here
      shape: BoxShape.circle,
    ),
  ),
  eventLoader: (day) {
    final events = _getEventsForDay(day);
    return events;
  },
),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedFilterCategory,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Categories'),
                ),
                ..._categories.map(
                  (cat) => DropdownMenuItem(
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
              children: _getEventsForDay(_selectedDay ?? _focusedDay).map((e) {
                final color = _categoryColors[e.category] ?? Colors.grey;

                return Card(
                  color: color.withOpacity(0.1),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => _showEditEventDialog(e),
                    onLongPress: () async {
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
                        await _deleteEvent(e.id);
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
