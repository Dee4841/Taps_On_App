import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Login.dart';

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
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            tooltip: 'Sign Out',
            onPressed: _signOut,
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
                _buildFeatureCard('Find A Tap', Icons.travel_explore),
                _buildFeatureCard('Finances', Icons.attach_money),
                _buildFeatureCard('Time Management', Icons.event),
                _buildFeatureCard('Tap Points', Icons.generating_tokens),
                _buildFeatureCard('Student Help', Icons.info),
                _buildFeatureCard('Marketplace', Icons.store),
              ],
            ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to the respective feature page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title tapped')),
        );
      },
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
