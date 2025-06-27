import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/validators.dart';
import '../services/auth_service.dart';
import 'signUp.dart';
import 'dashBoard.dart';
import 'admin_dash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'password_reset.dart';


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
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        ),
      ), 
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              //welcome message
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
                  child: Center(
                    child: Text(
                    'Welcome Back',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ) 
              ),
              
            //logo n text
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue[900]!.withAlpha((0.2 * 255).toInt()),
                            blurRadius: 40,
                            spreadRadius: 0,
                            offset: const Offset(0, 20), // drops shadow downward
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/images/water_drop.svg',
                        height: 100,
                        width: 100,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'TapsOnApp',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        height: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.0), // optional for better spacing
                    child: Image.asset(
                      'assets/icons/mail_icon.png',
                      height: 24,
                      width: 24,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                decoration:  InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.0), // optional for better spacing
                    child: Image.asset(
                      'assets/icons/lock_icon2.png',
                      height: 24,
                      width: 24,
                    ),
                  ),
                ),
                obscureText: true,
                validator: Validators.validatePassword,
              ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: null , // to be defined by Doyen
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

              
              const SizedBox(height: 30),

              _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // ✅ sets the background color
                    foregroundColor: Colors.white, // optional: sets text/icon color
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // optional styling
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
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
