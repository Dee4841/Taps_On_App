import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../services/auth_service.dart';
import 'dashBoard.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  //helper method -input decorator for white filling
  InputDecoration _whiteInput(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(color: Colors.black87),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blue),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

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
       backgroundColor: Colors.white,
       appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.blue,
        elevation: 0,
        titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        ), 
      ) ,
      body: Column(
        children: [
          const SizedBox(height: 20),
         Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Water drop with shadow
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[800]!.withAlpha((0.2 * 255).toInt()),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 20), // Shadow drops 3 pixels down
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/images/water_drop.svg',
                  height: 80,
                  width: 80,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'TapsOnApp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _whiteInput('Name'),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _surnameController,
                          decoration: _whiteInput('Surname'),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter your surname' : null,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: _whiteInput('Date of Birth'),
                            child: Text(
                              _selectedDate == null
                                  ? 'Tap to select date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _studentNumberController,
                          decoration: _whiteInput('Student Number'),
                          validator: (value) => value!.isEmpty
                              ? 'Enter your student number'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _institutionController,
                          decoration: _whiteInput('Institution'),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter your institution' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: _whiteInput('Year of Study'),
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
                          decoration: _whiteInput('Email'),
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmEmailController,
                          decoration: _whiteInput('Confirm Email'),
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
                          decoration: _whiteInput('Password'),
                          obscureText: true,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: _whiteInput('Confirm Password'),
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
                              activeColor: Colors.blue,
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
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue.shade900,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }
}
