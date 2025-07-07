import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudyTimeTrackerPage extends StatefulWidget {
  const StudyTimeTrackerPage({super.key});

  @override
  State<StudyTimeTrackerPage> createState() => _StudyTimeTrackerPageState();
}

class _StudyTimeTrackerPageState extends State<StudyTimeTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _durationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('study_sessions')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false);

    setState(() {
      _sessions = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final subject = _subjectController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;

    await Supabase.instance.client.from('study_sessions').insert({
      'user_id': user.id,
      'subject': subject,
      'duration': duration,
      'date': _selectedDate.toIso8601String().substring(0, 10),
    });

    _subjectController.clear();
    _durationController.clear();
    _selectedDate = DateTime.now();

    _fetchSessions();
  }

  Future<void> _updateSession(String id) async {
    final subject = _subjectController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;

    await Supabase.instance.client.from('study_sessions').update({
      'subject': subject,
      'duration': duration,
      'date': _selectedDate.toIso8601String().substring(0, 10),
    }).eq('id', id);

    _subjectController.clear();
    _durationController.clear();
    _selectedDate = DateTime.now();
    _fetchSessions();
  }

  Future<void> _deleteSession(String id) async {
    await Supabase.instance.client.from('study_sessions').delete().eq('id', id);
    _fetchSessions();
  }

  void _showEditDialog(Map<String, dynamic> session) {
    _subjectController.text = session['subject'];
    _durationController.text = session['duration'].toString();
    _selectedDate = DateTime.parse(session['date']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Session"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter a subject' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final num = int.tryParse(value ?? '');
                    return (num == null || num <= 0) ? 'Enter a valid duration' : null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(DateFormat('EEE, MMM d, yyyy').format(_selectedDate)),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Pick Date'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await _updateSession(session['id']);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Time Tracker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(labelText: 'Subject'),
                        validator: (value) => value == null || value.isEmpty ? 'Enter a subject' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final num = int.tryParse(value ?? '');
                          return (num == null || num <= 0) ? 'Enter a valid duration' : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('EEE, MMM d, yyyy').format(_selectedDate)),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Pick Date'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Log Study Session'),
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._sessions.map((s) => Dismissible(
                  key: ValueKey(s['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (dir) async {
                    return await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete Session"),
                        content: const Text("Are you sure you want to delete this session?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => _deleteSession(s['id']),
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(s['subject']),
                    subtitle: Text('${s['duration']} min • ${s['date']}'),
                    trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditDialog(s),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                          onPressed: () => _deleteSession(s['id']),
                              ),
                            ],
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
