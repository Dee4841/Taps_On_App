import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TimeJournalPage extends StatefulWidget {
  const TimeJournalPage({super.key});

  @override
  State<TimeJournalPage> createState() => _TimeJournalPageState();
}

class _TimeJournalPageState extends State<TimeJournalPage> {
  final _entryController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _entries = [];

  final List<String> _categories = [
    'Productive',
    'Leisure',
    'Social',
    'Rest',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('time_journal')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false);

    setState(() {
      _entries = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _submitEntry() async {
    final user = supabase.auth.currentUser;
    if (user == null || _entryController.text.trim().isEmpty) return;

    await supabase.from('time_journal').insert({
      'user_id': user.id,
      'entry_text': _entryController.text.trim(),
      'category': _selectedCategory,
      'date': _selectedDate.toIso8601String().substring(0, 10),
    });

    _entryController.clear();
    _selectedCategory = null;
    _selectedDate = DateTime.now();

    _fetchEntries();
  }

  Future<void> _deleteEntry(String id) async {
    await supabase.from('time_journal').delete().eq('id', id);
    _fetchEntries();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Time Journal")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _entryController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Reflect on your day... 📝',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      hint: const Text("Select Category"),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text(DateFormat.yMMMd().format(_selectedDate)),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickDate,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _submitEntry,
                icon: const Icon(Icons.save),
                label: const Text("Save Entry"),
              ),
              const SizedBox(height: 24),
              const Text('Past Entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._entries.map((e) => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(e['entry_text'] ?? ''),
                      subtitle: Text("${e['category'] ?? 'Uncategorized'} • ${e['date']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteEntry(e['id']),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
