import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/study/domain/study_session.dart';
import '../features/study/presentation/study_provider.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<StudyProvider>().loadSessions(userId);
      }
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final subject = _subjectController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;

    await context.read<StudyProvider>().addSession(
          userId: userId,
          subject: subject,
          duration: duration,
          date: _selectedDate,
        );

    _subjectController.clear();
    _durationController.clear();
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _updateSession({
  required String id,
  required String subject,
  required int duration,
  required DateTime date,
}) async {
  final userId = context.read<AuthProvider>().currentUser?.id;
  if (userId == null) return;
  await context.read<StudyProvider>().updateSession(
        userId: userId,
        id: id,
        subject: subject,
        duration: duration,
        date: date,
      );
}

  Future<void> _deleteSession(String id) async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    await context.read<StudyProvider>().deleteSession(
          userId: userId,
          id: id,
        );
  }

  Future<void> _showEditDialog(StudySession session) async {
  final result = await showDialog<_EditResult>(
    context: context,
    builder: (_) => _EditSessionDialog(session: session),
  );
  if (result == null || !mounted) return;
  await _updateSession(
    id: session.id,
    subject: result.subject,
    duration: result.duration,
    date: result.date,
  );
}

  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final sessions = studyProvider.sessions;

    return Scaffold(
      appBar: AppBar(title: const Text('Study Time Tracker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(labelText: 'Subject'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter a subject' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                            labelText: 'Duration (minutes)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final num = int.tryParse(value ?? '');
                          return (num == null || num <= 0)
                              ? 'Enter a valid duration'
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('EEE, MMM d, yyyy')
                              .format(_selectedDate)),
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
            const Text('Sessions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (studyProvider.isLoadingSessions)
              const Center(child: CircularProgressIndicator())
            else if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No sessions logged yet.'),
              )
            else
              ...sessions.map((s) => Dismissible(
                    key: ValueKey(s.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (dir) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Session"),
                          content: const Text(
                              "Are you sure you want to delete this session?"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel")),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete")),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) => _deleteSession(s.id),
                    child: Card(
                      child: ListTile(
                        title: Text(s.subject),
                        subtitle: Text(
                            "${s.duration} min • ${DateFormat('yyyy-MM-dd').format(s.date)}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditDialog(s),
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _EditResult {
  const _EditResult(this.subject, this.duration, this.date);
  final String subject;
  final int duration;
  final DateTime date;
}

class _EditSessionDialog extends StatefulWidget {
  const _EditSessionDialog({required this.session});
  final StudySession session;

  @override
  State<_EditSessionDialog> createState() => _EditSessionDialogState();
}

class _EditSessionDialogState extends State<_EditSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subjectCtrl =
      TextEditingController(text: widget.session.subject);
  late final TextEditingController _durationCtrl =
      TextEditingController(text: widget.session.duration.toString());
  late DateTime _date = widget.session.date;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _EditResult(
        _subjectCtrl.text.trim(),
        int.parse(_durationCtrl.text.trim()), // validated above
        _date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Session'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(labelText: 'Subject'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a subject' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationCtrl,
              decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                return (n == null || n <= 0) ? 'Enter a valid duration' : null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(DateFormat('EEE, MMM d, yyyy').format(_date)),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Pick Date'),
                  onPressed: _pickDate,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}