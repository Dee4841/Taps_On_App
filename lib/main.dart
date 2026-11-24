import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home.dart';
import 'pages/new_password.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'pages/login.dart';
import 'pages/dashboard.dart';
import 'pages/admin_dash.dart';
import 'core/config/env.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/presentation/profile_provider.dart';
import 'features/tasks/data/task_repository.dart';
import 'features/tasks/presentation/task_provider.dart';
import 'features/calendar/data/event_repository.dart';
import 'features/calendar/presentation/event_provider.dart';
import 'features/goals/data/goal_repository.dart';
import 'features/goals/presentation/goal_provider.dart';
import 'features/study/data/study_repository.dart';
import 'features/study/presentation/study_provider.dart';
import 'features/budget/data/budget_repository.dart';
import 'features/budget/presentation/budget_provider.dart';
import 'features/marketplace/data/marketplace_repository.dart';
import 'features/marketplace/presentation/marketplace_provider.dart';
import 'features/taps/data/taps_repository.dart';
import 'features/taps/presentation/taps_provider.dart';
import 'features/loyalty/data/loyalty_repository.dart';
import 'features/loyalty/presentation/loyalty_provider.dart';
import 'features/admin/data/admin_repository.dart';
import 'features/admin/presentation/admin_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepository())),
        ChangeNotifierProvider(create: (_) => ProfileProvider(ProfileRepository())),
        ChangeNotifierProvider(create: (_) => TaskProvider(TaskRepository())),
        ChangeNotifierProvider(create: (_) => EventProvider(eventRepository: EventRepository())),
        ChangeNotifierProvider(create: (_) => GoalProvider(goalRepository: GoalRepository())),
        ChangeNotifierProvider(create: (_) => StudyProvider(studyRepository: StudyRepository())),
        ChangeNotifierProvider(create: (_) => BudgetProvider(budgetRepository: BudgetRepository())),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider(marketplaceRepository: MarketplaceRepository())),
        ChangeNotifierProvider(create: (_) => TapsProvider(tapsRepository: TapsRepository())),
        ChangeNotifierProvider(create: (_) => LoyaltyProvider(loyaltyRepository: LoyaltyRepository())),
        ChangeNotifierProvider(create: (_) => AdminProvider(adminRepository: AdminRepository())),
      ],
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

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery && mounted) {
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

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isFirstLaunch) {
      return const HomePage();
    }

    final authProvider = context.watch<AuthProvider>();
    if (authProvider.isAuthenticated) {
      return authProvider.isAdmin ? const AdminDashboard() : const DashBoard();
    } else {
      return const LoginPage();
    }
  }
}
