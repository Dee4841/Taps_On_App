import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/profile/presentation/profile_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    _nameController = TextEditingController();
    _institutionController = TextEditingController();
    _studentNumberController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.loadProfile(userId);

    final profile = profileProvider.profile;
    _nameController.text = profile?.name ?? '';
    _institutionController.text = profile?.institution ?? '';
    _studentNumberController.text = profile?.studentNumber ?? '';
    _yearOfStudy = profile?.yearOfStudy;

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final profileProvider = context.read<ProfileProvider>();
    final success = await profileProvider.updateProfile(
      userId: userId,
      name: _nameController.text.trim(),
      institution: _institutionController.text.trim(),
      studentNumber: _studentNumberController.text.trim(),
      yearOfStudy: _yearOfStudy,
    );

    if (mounted) {
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Profile updated'
                : (profileProvider.errorMessage ?? 'Update failed'),
          ),
        ),
      );
    }
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
            onPressed: _isEditing
                ? _saveProfile
                : () {
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
                      decoration: const InputDecoration(labelText: 'Name'),
                      enabled: _isEditing,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _studentNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Student Number'),
                      enabled: _isEditing,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _institutionController,
                      decoration:
                          const InputDecoration(labelText: 'Institution'),
                      enabled: _isEditing,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _yearOfStudy,
                      items: _years
                          .map((year) =>
                              DropdownMenuItem(value: year, child: Text(year)))
                          .toList(),
                      onChanged: _isEditing
                          ? (value) => setState(() => _yearOfStudy = value)
                          : null,
                      decoration:
                          const InputDecoration(labelText: 'Year of Study'),
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
