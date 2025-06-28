import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home.dart';
import 'theme/app_theme.dart';
import 'pages/newpassWord.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://monvesaedughbmokesuw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vbnZlc2FlZHVnaGJtb2tlc3V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3NjEwNTUsImV4cCI6MjA2NjMzNzA1NX0.HdOxDIRpNp6L5QbFz9Dzbyum2hqqC3_T5Bjsy9ncJvY',
       
  );

  runApp(const MainApp());
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfect Water',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // User is resetting password → navigate to reset screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NewPasswordPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage(); // Your login or landing page
  }
}
