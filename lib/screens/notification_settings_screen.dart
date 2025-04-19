import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  List<Medication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadMedications();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('notification_sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('notification_vibration_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('notification_sound_enabled', _soundEnabled);
    await prefs.setBool('notification_vibration_enabled', _vibrationEnabled);
  }

  Future<void> _loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');
    
    if (listString != null) {
      List decoded = jsonDecode(listString);
      List<Prescription> prescriptions = decoded
          .map((e) => Prescription.fromJson(e))
          .toList();
      
      List<Medication> allMedications = [];
      for (var prescription in prescriptions) {
        allMedications.addAll(prescription.medications.where((med) => med.isActive));
      }
      
      setState(() {
        _medications = allMedications;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildGlobalSettingsCard(),
            SizedBox(height: 16),
            _buildMedicationNotificationsCard(),
          ],
        ),
    );
  }

  Widget _buildGlobalSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Global Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Enable Notifications'),
              subtitle: Text('Turn on/off all medication reminders'),
              value: _notificationsEnabled,
              onChanged: (bool value) async {
                setState(() => _notificationsEnabled = value);
                await _saveSettings();
                if (!value) {
                  // Cancel all notifications if disabled
                  await FlutterLocalNotificationsPlugin().cancelAll();
                } else {
                  // Reschedule notifications for all active medications
                  // This will use the existing scheduling logic
                  await scheduleMedicationNotifications();
                }
              },
            ),
            SwitchListTile(
              title: Text('Sound'),
              subtitle: Text('Play sound with notifications'),
              value: _soundEnabled,
              onChanged: _notificationsEnabled ? (bool value) async {
                setState(() => _soundEnabled = value);
                await _saveSettings();
              } : null,
            ),
            SwitchListTile(
              title: Text('Vibration'),
              subtitle: Text('Vibrate with notifications'),
              value: _vibrationEnabled,
              onChanged: _notificationsEnabled ? (bool value) async {
                setState(() => _vibrationEnabled = value);
                await _saveSettings();
              } : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationNotificationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medication Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (_medications.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No active medications found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final medication = _medications[index];
                  return _buildMedicationNotificationItem(medication);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationNotificationItem(Medication medication) {
    return ExpansionTile(
      title: Text(medication.name),
      subtitle: Text('${medication.frequency} - ${medication.reminderTimes.length} times'),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminder Times:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              ...medication.reminderTimes.asMap().entries.map((entry) {
                int index = entry.key;
                TimeOfDay time = entry.value;
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.access_time),
                  title: Text(_formatTime(time)),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editReminderTime(medication, index),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _editReminderTime(Medication medication, int index) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: medication.reminderTimes[index],
    );

    if (newTime != null) {
      setState(() {
        medication.reminderTimes[index] = newTime;
      });
      // Update medication in storage and reschedule notifications
      await _updateMedicationTime(medication);
    }
  }

  Future<void> _updateMedicationTime(Medication medication) async {
    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');

    if (listString != null) {
      List decoded = jsonDecode(listString);
      List<Prescription> prescriptions = decoded
          .map((e) => Prescription.fromJson(e))
          .toList();

      for (var prescription in prescriptions) {
        final medIndex = prescription.medications
            .indexWhere((m) => m.id == medication.id);
        if (medIndex != -1) {
          prescription.medications[medIndex] = medication;
          break;
        }
      }

      // Save updated prescriptions
      final updatedString = jsonEncode(prescriptions.map((e) => e.toJson()).toList());
      await prefs.setString('prescriptions', updatedString);

      // Reschedule notifications
      await scheduleMedicationNotifications();
    }
  }

  Future<void> scheduleMedicationNotifications() async {
    // This will use the existing scheduling logic from settings_screen.dart
    // You'll need to implement this based on your notification scheduling needs
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }
} 