import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://monvesaedughbmokesuw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vbnZlc2FlZHVnaGJtb2tlc3V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3NjEwNTUsImV4cCI6MjA2NjMzNzA1NX0.HdOxDIRpNp6L5QbFz9Dzbyum2hqqC3_T5Bjsy9ncJvY',
  );
  runApp(MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfect Water',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}

