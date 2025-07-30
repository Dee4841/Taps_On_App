import 'package:flutter/material.dart';
import 'package:p_water/pages/student_help.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Login.dart';
import 'time_management_options.dart';
import 'LoyaltyPointsPage.dart';
import 'financial_budgeting.dart';
import 'student_help.dart';
import 'profile.dart';
import 'market_place.dart';
import 'settings.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final SupabaseClient _client = Supabase.instance.client;
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final response = await _client
        .from('students')
        .select()
        .eq('id', user.id)
        .single();

    setState(() {
      _profileData = response;
      _isLoading = false;
    });
  }
  
void _showAboutDialog() {
  showAboutDialog(
    context: context,
    applicationName: 'TapsOnApp',
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2025 TapsOnApp Team',
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('A student-focused time and resource management app.'),
      ),
    ],
  );
}
  Future<void> _signOut() async {
    await _client.auth.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _profileData?['name'] ?? 'Student';

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $userName'),
        backgroundColor: Colors.blue,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        actions: [
    PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'view':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfilePage()),
            );
            break;
          case 'settings':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_)=> SettingsPage()),
            );
            break;
          case 'about':
            _showAboutDialog();
            break;
          case 'signout':
            _signOut();
            break;
        }
      },
      icon: const Icon(Icons.more_vert, color: Colors.white),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'view', child: Text('View Profile')),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
        const PopupMenuItem(value: 'about', child: Text('About')),
        const PopupMenuItem(value: 'signout', child: Text('LogOut')),
      ],
    ),
  ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                __buildFeatureCard('Find A Tap', 
                Icons.travel_explore,
                onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FindTapPage()),
                    );
                  },
                  ),
              _buildFeatureCard(
                'Finances',
               Icons.attach_money,
               onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FinancialBudgetingPage(),
                 ),
               );
           },
        ),

                _buildFeatureCard(
                  'Time Management', 
                  Icons.event,
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (_) => const TimeManagementOptionsPage(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  'Tap Points',
                  Icons.star,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoyaltyPointsPage()),
                    );
                  },
                ),
                _buildFeatureCard('Student Help',
                 Icons.info,
                 onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentHelpPage()),
                  );

                 }),
                _buildFeatureCard(
                  'Marketplace',
                  Icons.store,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MarketplacePage()),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
          onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
