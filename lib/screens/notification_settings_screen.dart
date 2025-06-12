import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/services/notification_service.dart';
import 'package:med_track/services/voice_service.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:developer' as developer;


class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  List<Medication> _medications = [];
  bool _isLoading = true;
  Map<String, String?> _medicationSounds = {}; // Store sound file paths for each medication

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

                  await _notificationService.cancelAllNotification();
                } else {
                  await _notificationService.setScheduleNotification();
                }
              },
            ),
            SwitchListTile(
              title: Text(localizations.sound),
              subtitle: Text(localizations.shareApp),
              value: _soundEnabled,
              onChanged: _notificationsEnabled ? (bool value) async {
                setState(() => _soundEnabled = value);

                if(!value){

                  await _notificationService.muteNotifications();
                }else{
                  await _notificationService.unmuteNotifications();
                }
                await _saveSettings();
              } : null,
            ),
            SwitchListTile(
              title: Text(localizations.vibration),
              subtitle: Text(localizations.vibration),
              value: _vibrationEnabled,
              onChanged: _notificationsEnabled ? (bool value) async {
                setState(() => _vibrationEnabled = value);
                if(!value){

                  await _notificationService.setVibration("medication_channel", false);
                }else{
                  await _notificationService.setVibration("medication_channel", true);
                }
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
                    icon: Icon(Icons.edit_outlined),
                    onPressed: () => _editReminderTime(medication, index),
                  ),
                );
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  buildRecordingButton(context,medication),
                  // TextButton.icon(
                  //   onPressed: () async{
                  //     final recorderService = RecorderService();
                  //
                  //     try {
                  //       // Start recording
                  //       final filePath = await recorderService.startRecording("my_recording");
                  //       print("Recording to: $filePath");
                  //
                  //       // Check if recording
                  //       final isRecording = await recorderService.isRecording();
                  //       print("Is recording: $isRecording");
                  //
                  //       // Stop recording after some time
                  //       await Future.delayed(Duration(seconds: 5));
                  //     final recordedFile = await recorderService.stopRecording();
                  //     print("Recorded file: $recordedFile");
                  //
                  //     // Clean up
                  //     await recorderService.dispose();
                  //     } catch (e) {
                  //     log("Error: $e");
                  //     }
                  //     // Your action
                  //   },
                  //   icon: Icon(Icons.record_voice_over_outlined),
                  //   label: Text('Voice'),
                  // ),

                ],
              ),
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
      await _notificationService.cancelAllNotification();
      await _notificationService.setScheduleNotification();
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
      await _notificationService.setScheduleNotification();
    }
  }




  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }

  void showRecordingDialog(BuildContext context, Future<String?> Function() onStop) {
    int secondsElapsed = 0;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            timer ??= Timer.periodic(Duration(seconds: 1), (timer) {
              setState(() {
                secondsElapsed++;
              });
            });

            return AlertDialog(
              title: Text('Recording'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Recording time: ${formatDuration(secondsElapsed)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    timer?.cancel();
                    Navigator.of(context).pop();
                    final filePath = await onStop();
                    if (filePath != null) {
                      await playAudio(filePath, context);


                    }
                  },
                  child: Text('Stop'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      timer?.cancel();
    });
  }

  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Future<void> playAudio(String filePath, BuildContext context) async {
    final player = AudioPlayer();
    try {
      await player.setFilePath(filePath);
      await player.play();
    } catch (e) {
      developer.log("Error playing audio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to play audio: $e")),
      );
    } finally {
      await player.dispose();
    }
  }

  Widget buildRecordingButton(BuildContext context,Medication medication) {


    return TextButton.icon(
      onPressed: () async {
        final recorderService = RecorderService();

        try {
          final filePath = await recorderService.startRecording(medication.id);
          developer.log("Recording to: $filePath");

          final isRecording = await recorderService.isRecording();
          developer.log("Is recording: $isRecording");

          showRecordingDialog(context, () async => await recorderService.stopRecording());

        //  Remove this block if stopping only via dialog
          await Future.delayed(Duration(seconds: 5));
          Navigator.pop(context);
          final recordedFile = await recorderService.stopRecording();
          developer.log("Recorded file: $recordedFile");
          if (recordedFile != null) {
            await playAudio(recordedFile, context);

            recordAndAssignAudio(medication,recordedFile);
          }

          await recorderService.dispose();
        } catch (e) {
          developer.log("Error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      },
      icon: Icon(Icons.record_voice_over_outlined),
      label: Text('Voice/analysis'),
    );
  }



  Future<void> recordAndAssignAudio(Medication medication,String filePath) async {
    try {
      // Start recording


      // Load existing prescriptions
      final prefs = await SharedPreferences.getInstance();
      final String? listString = prefs.getString('prescriptions');
      if (listString != null) {
        final List decoded = jsonDecode(listString);
        final List<Prescription> prescriptions =
        decoded.map((e) => Prescription.fromJson(e)).toList();

        // Update the specific medication
        for (var prescription in prescriptions) {
          for (var med in prescription.medications) {
            if (med.id == medication.id) {
              // Create a new Medication instance with updated audioFilePath
              final updatedMed = Medication(
                name: med.name,
                notes: med.notes,
                remainderDates: med.remainderDates,
                reminderTimes: med.reminderTimes,
                audioFilePath: filePath,
                id: med.id,
                timesPerDay: med.timesPerDay,
                stock: med.stock,
                isActive: med.isActive,
                isTaken: med.isTaken,
                frequency: med.frequency,
              );
              // Replace the old medication in the list
              prescription.medications[prescription.medications.indexOf(med)] =
                  updatedMed;
            }
          }
        }

        // Save updated prescriptions
        await prefs.setString(
            'prescriptions', jsonEncode(prescriptions.map((p) => p.toJson()).toList()));
      }
          await _notificationService.cancelAllNotification();
      await _notificationService.setScheduleNotification();
    } catch (e) {
      print('Error recording audio: $e');
    }
  }

} 