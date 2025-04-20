import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/utils/app_localizations.dart';
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
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          localizations.notifications,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildGlobalSettingsCard(localizations),
            SizedBox(height: 16),
            _buildMedicationNotificationsCard(localizations),
          ],
        ),
    );
  }

  Widget _buildGlobalSettingsCard(AppLocalizations localizations) {
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
              localizations.appSettings,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text(localizations.enableDisableNotifications),
              subtitle: Text(localizations.enableDisableNotifications),
              value: _notificationsEnabled,
              onChanged: (bool value) async {
                setState(() => _notificationsEnabled = value);
                await _saveSettings();
                if (!value) {
                  await FlutterLocalNotificationsPlugin().cancelAll();
                } else {
                  await scheduleMedicationNotifications();
                }
              },
            ),
            SwitchListTile(
              title: Text(localizations.sound),
              subtitle: Text(localizations.shareApp),
              value: _soundEnabled,
              onChanged: _notificationsEnabled ? (bool value) async {
                setState(() => _soundEnabled = value);
                await _saveSettings();
              } : null,
            ),
            SwitchListTile(
              title: Text(localizations.vibration),
              subtitle: Text(localizations.vibration),
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

  Widget _buildMedicationNotificationsCard(AppLocalizations localizations) {
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
              localizations.reminderTimes,
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
                    localizations.noMedications,
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
                  return _buildMedicationNotificationItem(medication, localizations);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationNotificationItem(Medication medication, AppLocalizations localizations) {
    return ExpansionTile(
      title: Text(medication.name),
      subtitle: Text('${medication.frequency} - ${medication.reminderTimes.length} ${localizations.timesPerDay}'),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.reminderTimes,
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