import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'newPassWord.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${info.version} (Build ${info.buildNumber})';
    });
  }


  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action is irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('students').delete().eq('id', user.id);
        await Supabase.instance.client.auth.signOut();
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: (){
                Navigator.push(
              context,
              MaterialPageRoute(builder: (_)=> NewPasswordPage()),
            );
            }
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete Account'),
            onTap: _confirmDeleteAccount,
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
                secondary: const Icon(Icons.brightness_6),
                title: const Text("Dark Theme"),
                value: themeProvider.isDarkMode,
                onChanged: (_) =>{
                  themeProvider.toggleTheme(),
                },
              ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: Text(_appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                  title: Text('Privacy Policy'),
                  content: Text('This is a placeholder for the privacy policy.'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Terms & Conditions'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                  title: Text('Terms & Conditions'),
                  content: Text('This is a placeholder for the terms and conditions.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}