import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _dataCollection = true;
  bool _showMedNames = true;
  bool _biometricLock = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dataCollection = prefs.getBool('data_collection') ?? true;
      _showMedNames = prefs.getBool('show_med_names') ?? true;
      _biometricLock = prefs.getBool('biometric_lock') ?? false;
    });
  }

  Future<void> _savePrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('data_collection', _dataCollection);
    await prefs.setBool('show_med_names', _showMedNames);
    await prefs.setBool('biometric_lock', _biometricLock);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Privacy Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          // Privacy Policy Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your privacy is important to us. This section controls how your data is handled within MedTrack.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // Privacy Settings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Data Privacy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          // Data Collection Setting
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              title: const Text('Data Collection'),
              subtitle: const Text('Allow anonymous usage data collection to improve the app'),
              secondary: Icon(
                Icons.analytics_outlined,
                color: Theme.of(context).primaryColor,
              ),
              value: _dataCollection,
              onChanged: (bool value) {
                setState(() {
                  _dataCollection = value;
                  _savePrivacySettings();
                });
              },
            ),
          ),

          // Medication Names Visibility
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              title: const Text('Show Medication Names'),
              subtitle: const Text('Show medication names in notifications and widgets'),
              secondary: Icon(
                Icons.visibility,
                color: Theme.of(context).primaryColor,
              ),
              value: _showMedNames,
              onChanged: (bool value) {
                setState(() {
                  _showMedNames = value;
                  _savePrivacySettings();
                });
              },
            ),
          ),

          // Biometric Lock
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              title: const Text('Biometric Lock'),
              subtitle: const Text('Require authentication to open the app'),
              secondary: Icon(
                Icons.fingerprint,
                color: Theme.of(context).primaryColor,
              ),
              value: _biometricLock,
              onChanged: (bool value) {
                setState(() {
                  _biometricLock = value;
                  _savePrivacySettings();
                });
              },
            ),
          ),

          // Data Management Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Data Management',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          // Export Data
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.download,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('Export Your Data'),
              subtitle: const Text('Download a copy of your data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement data export functionality
              },
            ),
          ),

          // Delete Data
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              title: const Text('Delete All Data'),
              subtitle: const Text('Permanently remove all your data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete All Data?'),
                    content: const Text(
                      'This action cannot be undone. All your medication history and settings will be permanently deleted.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement data deletion
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'DELETE',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 