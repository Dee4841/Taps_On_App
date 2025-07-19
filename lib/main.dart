import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home.dart';
import 'pages/newPassWord.dart';
import 'package:provider/provider.dart';
import 'pages/theme_provider.dart';
import 'pages/Login.dart';
import 'pages/dashBoard.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://monvesaedughbmokesuw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vbnZlc2FlZHVnaGJtb2tlc3V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3NjEwNTUsImV4cCI6MjA2NjMzNzA1NX0.HdOxDIRpNp6L5QbFz9Dzbyum2hqqC3_T5Bjsy9ncJvY',
       
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}
class MainApp extends StatelessWidget {
  
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'TapsOnApp',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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
 bool _isLoading = true;
  bool _isFirstLaunch = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
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

   Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('hasLaunched') ?? false;

    if (!hasLaunched) {
      await prefs.setBool('hasLaunched', true);
      _isFirstLaunch = true;
    }

    final session = Supabase.instance.client.auth.currentSession;
    _isLoggedIn = session != null;

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isFirstLaunch) {
      return const HomePage();
    }

    if (_isLoggedIn) {
      return const DashBoard(); 
    } else {
      return const LoginPage();
    }
  }
}
