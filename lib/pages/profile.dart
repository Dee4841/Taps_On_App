import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient _client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _institutionController;
  late TextEditingController _studentNumberController;
  bool _isLoading = true;
  bool _isEditing = false;

  String? _yearOfStudy;
  final List<String> _years = [
  '1st Year',
  '2nd Year',
  '3rd Year',
  '4th Year',
  'Postgraduate',
];


  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final response = await _client
        .from('students')
        .select()
        .eq('id', user.id)
        .single();

    _nameController = TextEditingController(text: response['name'] as String?);
    _institutionController = TextEditingController(text: response['institution'] as String?);
    _studentNumberController = TextEditingController(text: response['student_number'] as String?);
    _yearOfStudy = response['year_of_study'] as String?;


    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = _client.auth.currentUser;
    await _client.from('students').update({
      'name': _nameController.text,
      'institution': _institutionController.text,
      'student_number': _studentNumberController.text,
      'year_of_study': _yearOfStudy,
    }).eq('id', user!.id);

    

    setState(() {
      _isEditing = false;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated'))
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _isEditing ? _saveProfile : () {
              setState(() => _isEditing = true);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      enabled: _isEditing,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _studentNumberController,
                      decoration: InputDecoration(labelText: 'Student Number'),
                      enabled: _isEditing,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _institutionController,
                      decoration: InputDecoration(labelText: 'Institution'),
                      enabled: _isEditing,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),

                    const SizedBox(height: 12),
DropdownButtonFormField<String>(
  value: _yearOfStudy,
  items: _years
      .map((year) => DropdownMenuItem(value: year, child: Text(year)))
      .toList(),
  onChanged: _isEditing
      ? (value) => setState(() => _yearOfStudy = value)
      : null,
  decoration: const InputDecoration(labelText: 'Year of Study'),
  validator: (value) =>
      value == null || value.isEmpty ? 'Required' : null,
),

                  ],
                ),
              ),
            ),
    );
  }
}
