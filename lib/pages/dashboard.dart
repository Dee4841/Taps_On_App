import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/profile/presentation/profile_provider.dart';
import '../features/taps/presentation/taps_provider.dart';
import 'login.dart';
import 'time_management_options.dart';
import 'loyalty_points_page.dart';
import 'financial_budgeting.dart';
import 'student_help.dart';
import 'profile.dart';
import 'market_place.dart';
import 'settings.dart';
import 'find_tap.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    FindTapPage(showAppBar: false),
    FinancialBudgetingPage(),
    TimeManagementOptionsPage(),
    LoyaltyPointsPage(),
    MarketplacePage(),
    StudentHelpPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    await context.read<ProfileProvider>().loadProfile(userId);
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'TapsOnApp',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 TapsOnApp Team',
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('A student-focused time and resource management app.'),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    await context.read<AuthProvider>().signOut();

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
    final profile = context.watch<ProfileProvider>().profile;
    final userName = profile?.name.isNotEmpty == true ? profile!.name : 'Student';

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
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
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh Taps',
                  onPressed: () => context.read<TapsProvider>().loadTaps(),
                ),
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
                          MaterialPageRoute(builder: (_) => SettingsPage()),
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
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'view', child: Text('View Profile')),
                    PopupMenuItem(value: 'settings', child: Text('Settings')),
                    PopupMenuItem(value: 'about', child: Text('About')),
                    PopupMenuItem(value: 'signout', child: Text('LogOut')),
                  ],
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    const items = [
      _NavItem(icon: Icons.travel_explore, label: 'Home'),
      _NavItem(icon: Icons.attach_money, label: 'Finances'),
      _NavItem(icon: Icons.event, label: 'Time'),
      _NavItem(icon: Icons.star, label: 'Points'),
      _NavItem(icon: Icons.store, label: 'Market'),
      _NavItem(icon: Icons.info, label: 'Help'),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final isSelected = _selectedIndex == index;
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey[300] : Colors.grey[700]),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
