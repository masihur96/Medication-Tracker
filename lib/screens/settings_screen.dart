import 'package:flutter/material.dart';
import 'package:med_track/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import 'history_screen.dart';
import 'privacy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('dark_mode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          // User Profile Card
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.person, size: 35, color: Colors.white),
              ),
              title: const Text(
                'Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Manage your profile information',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen()));
                // Navigate to profile screen
              },
            ),
          ),

          // Settings Sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'App Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          // History Option (New Addition)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.history,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('Medication History'),
              subtitle: const Text('View your medication tracking history'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryScreen(
                    ),
                  ),
                );
                // Navigate to history screen
                // TODO: Implement navigation to History screen
              },
            ),
          ),

          // Notification Settings
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Enable or disable notifications'),
              secondary: Icon(
                Icons.notifications,
                color: Theme.of(context).primaryColor,
              ),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                  _saveSettings();
                });
              },
            ),
          ),

          // Theme Settings
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              title: const Text('Dark Theme'),
              subtitle: const Text('Switch between light and dark theme'),
              secondary: Icon(
                Icons.dark_mode,
                color: Theme.of(context).primaryColor,
              ),
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                  _saveSettings();
                });
              },
            ),
          ),

          const SizedBox(height: 16),
          
          // Additional Settings Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'More Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          // Privacy Settings
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.privacy_tip,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('Privacy'),
              subtitle: const Text('Manage your privacy settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                );
              },
            ),
          ),

          // Tell a Friend
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.share,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('Tell a Friend'),
              subtitle: const Text('Share this app with friends'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                const String appLink = "https://medtrack.app"; // Replace with your actual app link
                const String message = "Check out MedTrack - Your personal medication tracking assistant! Download it here: ";
                await Share.share('$message$appLink');
              },
            ),
          ),

          // About
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.info,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('About'),
              subtitle: const Text('Learn more about MedTrack'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'MedTrack',
                  applicationVersion: '1.0.0',
                  applicationIcon: const FlutterLogo(),
                  children: [
                    const Text(
                      'MedTrack is your personal medication tracking assistant, '
                      'helping you stay on top of your medication schedule and '
                      'maintain better health.',
                    ),
                  ],
                );
              },
            ),
          ),

          // Version Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 