import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_track/main.dart';
import 'package:med_track/providers/theme_provider.dart';
import 'package:med_track/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/medication.dart';
import '../models/prescription.dart';
import 'history_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_screen.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';

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

              ),
            ),
          ),

          // History Option (New Addition)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.history,

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
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NotificationSettingsScreen()),
                );
              },
              leading: Icon(
                Icons.notifications,

              ),
              title: const Text('Notifications'),
              subtitle: const Text('Enable or disable notifications'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) async {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  await _saveSettings();

                  final medications = await getMedications(); // Implement this
                  if (_notificationsEnabled) {
                    await scheduleDailyAlarms(medications);
                  } else {
                    await cancelAllNotifications();
                  }
                },
              ),
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

              ),
              value: _isDarkMode,
              onChanged: (bool value) async {
                setState(() {
                  _isDarkMode = value;
                });
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                await _saveSettings();
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

              ),
            ),
          ),

          // Privacy Settings
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.privacy_tip,

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

              ),
              title: const Text('About'),
              subtitle: const Text('Learn more about MedTrack'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {

                showCustomAboutDialog(context);
                // showAboutDialog(
                //   context: context,
                //   applicationName: 'MedTrack',
                //   applicationVersion: '1.0.0',
                //   applicationIcon: const FlutterLogo(),
                //   useRootNavigator: false,
                //
                //   children: [
                //     const Text(
                //       'MedTrack is your personal medication tracking assistant, '
                //       'helping you stay on top of your medication schedule and '
                //       'maintain better health.',
                //     ),
                //   ],
                // );
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
  Future<void> cancelAllNotifications() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleDailyAlarms([List<Medication>? medications]) async {
    if (!_notificationsEnabled) {
      // Cancel all notifications if notifications are disabled
      await flutterLocalNotificationsPlugin.cancelAll();
      return;
    }

    // Request notification permissions for iOS
    final settings = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // For Android 13 and above, request notification permission
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      final granted = await androidImplementation?.requestNotificationsPermission();
      if (granted != true) {
        return; // Exit if permission not granted
      }
    }

    // Cancel existing notifications before scheduling new ones
    await flutterLocalNotificationsPlugin.cancelAll();

    if (medications == null || medications.isEmpty) {
      return;
    }

    int notificationId = 0;
    for (var medication in medications) {
      for (int i = 0; i < medication.reminderTimes.length; i++) {
        final time = medication.reminderTimes[i];
        
        final now = DateTime.now();
        final scheduledTime = DateTime(
          now.year, 
          now.month, 
          now.day, 
          time.hour, 
          time.minute
        );

        // If the time is already passed today, schedule for tomorrow
        final adjustedTime = scheduledTime.isBefore(now)
            ? scheduledTime.add(const Duration(days: 1))
            : scheduledTime;

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId++, // Unique ID per notification
          'Time for ${medication.name}',
          'Please take ${medication.dosage} of ${medication.name}\n${medication.notes ?? ''}',
          tz.TZDateTime.from(adjustedTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_channel_id',
              'Medication Reminders',
              channelDescription: 'Daily medication reminders',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  void showCustomAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const FlutterLogo(),
              const SizedBox(width: 12),
              const Text('MedTrack'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Version: 1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'MedTrack is your personal medication tracking assistant, '
                    'helping you stay on top of your medication schedule and '
                    'maintain better health.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  Future<List<Medication>> getMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');
    List<Medication> allMedications = [];
    
    if (listString != null) {
      final List decoded = jsonDecode(listString);
      final List<Prescription> prescriptions = decoded.map((e) => Prescription.fromJson(e)).toList();
      
      // Collect all active medications from all prescriptions
      for (var prescription in prescriptions) {
        allMedications.addAll(prescription.medications.where((med) => med.isActive));
      }
    }
    
    return allMedications;
  }

} 