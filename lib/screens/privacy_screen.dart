import 'package:flutter/material.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import '../services/local_repository.dart';


class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricsAvailable = false;
  bool _dataCollection = true;
  bool _showMedNames = true;
  bool _biometricLock = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
    _checkBiometricsAvailability();
  }
  Future<void> shareExportedFile() async {
     final  file = await LocalRepository().exportDataToFile();
    if (file != null && await file.exists()) {
      Share.shareXFiles([XFile(file.path)], text: 'Here is my prescription backup');
    }
  }
  Future<void> _checkBiometricsAvailability() async {
    final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    
    setState(() {
      _isBiometricsAvailable = canAuthenticate;
    });
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
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          localizations.privacy,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                  localizations.privacy,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.managePrivacy,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // Privacy Settings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              localizations.dataPrivacy,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),


          // Biometric Lock
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              title: Text(localizations.biometricLock),
              subtitle: Text(_isBiometricsAvailable 
                ? localizations.biometricLockDescription 
                : localizations.biometricsNotAvailable),
              secondary: Icon(
                Icons.fingerprint,
                color: _isBiometricsAvailable ? null : Colors.grey,
              ),
              value: _biometricLock,
              onChanged: _isBiometricsAvailable 
                ? (bool value) {
                    setState(() {
                      _biometricLock = value;
                      _savePrivacySettings();
                    });
                  }
                : null,
            ),
          ),

          // Data Management Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              localizations.dataManagement,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Export Data
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.download,
              ),
              title: Text(localizations.exportData),
              subtitle: Text(localizations.exportDataDescription),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                shareExportedFile(); // Call the method to share the exported file

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
              title: Text(localizations.deleteAllData),
              subtitle: Text(localizations.deleteAllDataDescription),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(localizations.deleteAllDataConfirm),
                    content: Text(localizations.deleteAllDataWarning),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(localizations.cancel),
                      ),
                      TextButton(
                        onPressed: () async{
                         await LocalRepository.deleteAllData(); // Assuming you have a method to delete all data
                          // TODO: Implement data deletion
                          Navigator.pop(context);
                        },
                        child: Text(
                          localizations.delete,
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