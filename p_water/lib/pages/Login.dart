import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/validators.dart';
import '../services/auth_service.dart';
import 'signUp.dart';
import 'dashBoard.dart';
import 'admin_dash.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
void _handleLogin() async {
  // Validate form
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    // 1. Perform login
    final authService = AuthService();
    final error = await authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (error != null) {
      throw Exception(error);
    }

    // 2. Get authenticated user
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      throw Exception('Authentication failed - no user ID');
    }

    // 3. Fetch user role
    final response = await Supabase.instance.client
        .from('students')
        .select('role')
        .eq('id', user.id)
        .maybeSingle()
        .timeout(const Duration(seconds: 10));

    final role = (response != null && response['role'] != null)
        ? response['role'] as String
        : 'student';

    // 4. Navigate based on role
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => role == 'admin' 
            ? const AdminDashboard() 
            : const DashBoard(),
      ),
    );

  } catch (e) {
    // Handle all errors in one place
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login error: ${e.toString().replaceAll('Exception: ', '')}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    // Ensure loading state is always false
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                    ),
              const SizedBox(height: 16),

              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    const TextSpan(text: "Don't have an account? "),
                    TextSpan(
                      text: "Sign Up",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _goToSignUp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
