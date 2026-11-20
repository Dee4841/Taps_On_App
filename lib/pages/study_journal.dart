import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/study/presentation/study_provider.dart';

class TimeJournalPage extends StatefulWidget {
  const TimeJournalPage({super.key});

  @override
  State<TimeJournalPage> createState() => _TimeJournalPageState();
}

class _TimeJournalPageState extends State<TimeJournalPage> {
  final _entryController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<StudyProvider>().loadJournalEntries(userId);
      }
    });
  }

  Future<void> _submitEntry() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    final text = _entryController.text.trim();
    if (userId == null || text.isEmpty) return;

    await context.read<StudyProvider>().addJournalEntry(
          userId: userId,
          entryText: text,
          category: _selectedCategory,
          date: _selectedDate,
        );

    _entryController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _deleteEntry(String id) async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    await context.read<StudyProvider>().deleteJournalEntry(
          userId: userId,
          id: id,
        );
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
    final studyProvider = context.watch<StudyProvider>();
    final entries = studyProvider.journalEntries;

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
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
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
              const Text('Past Entries',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (studyProvider.isLoadingJournal)
                const Center(child: CircularProgressIndicator())
              else if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No journal entries yet.'),
                )
              else
                ...entries.map((e) => Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(e.entryText),
                        subtitle: Text(
                            "${e.category ?? 'Uncategorized'} • ${e.date}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteEntry(e.id),
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
