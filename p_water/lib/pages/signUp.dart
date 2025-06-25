import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../services/auth_service.dart';
import 'dashBoard.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _institutionController = TextEditingController();

  DateTime? _selectedDate;
  String? _yearOfStudy;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final List<String> _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Postgraduate',
  ];

  void _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate() || !_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form and accept terms.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = AuthService();
    final error = await authService.signUpStudent(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      dob: _selectedDate!,
      studentNumber: _studentNumberController.text.trim(),
      institution: _institutionController.text.trim(),
      yearOfStudy: _yearOfStudy!,
      
    );

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $error')),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashBoard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: 'Surname'),
                validator: (value) => value!.isEmpty ? 'Enter your surname' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Tap to select date'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentNumberController,
                decoration: const InputDecoration(labelText: 'Student Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your student number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(labelText: 'Institution'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your institution' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Year of Study'),
                items: _years
                    .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _yearOfStudy = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select your year of study' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmEmailController,
                decoration: const InputDecoration(labelText: 'Confirm Email'),
                validator: (value) {
                  if (value != _emailController.text) {
                    return 'Emails do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value!;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to the Terms & Conditions',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleSignUp,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        child: Text('Sign Up', style: TextStyle(fontSize: 18)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
