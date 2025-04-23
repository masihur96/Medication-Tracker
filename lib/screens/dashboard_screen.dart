import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/screens/notification_screen.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_medication_history.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle notification tap in background
  print('Notification tapped in background: ${notificationResponse.payload}');
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Medication> _todaysMedications = [];
  Map<DateTime, int> _heatMapDataset = {};
  List<Prescription> _prescriptions = [];
  Prescription? _selectedPrescription;
  List<EnhancedMedicationHistory> _medicationHistory = [];
  bool _isLoading = true;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  @override
  void initState() {
    super.initState();
    // Initialize notifications
    _initializeNotifications();
    // Initialize data
    initializeData();
  }

  Future<void> _initializeNotifications() async {
    try {
      tz.initializeTimeZones();
      
      const androidInitialize = AndroidInitializationSettings('logo');
      final iOSInitialize = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            'medication_category',
            actions: [
              DarwinNotificationAction.plain('take', 'Take'),
              DarwinNotificationAction.plain('skip', 'Skip'),
            ],
            options: {
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            },
          ),
        ],
      );
      final initializationSettings = InitializationSettings(
        android: androidInitialize,
        iOS: iOSInitialize,
      );
      
      // Add debug print before initialization
      print('Initializing notifications...');
      
      bool? initialized = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
          // Handle notification tap
          print('Notification received: ${notificationResponse.payload}');
          if (notificationResponse.payload != null) {
            // Navigate to relevant screen or perform action
            print('Notification payload: ${notificationResponse.payload}');
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      
      print('Notifications initialized: $initialized');

      // Request permissions
      await _requestNotificationPermissions();
      
      // Test if notifications work immediately
      await flutterLocalNotificationsPlugin.show(
        0,
        'Initialization Test',
        'Testing if notifications are working',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Test notification channel',
            importance: Importance.max,
            priority: Priority.max,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      
      print('Test notification sent');
    } catch (e, stackTrace) {
      print('Error in notification initialization: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _requestNotificationPermissions() async {
    // Request permissions for iOS
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true, // Enable critical alerts
          );
    }

    // Request notification permission for Android
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        print('Notification permission denied');
      }
    }
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> initializeData() async {
    setState(() => _isLoading = true);
    // Load both data sources
    await loadPrescriptions();
    await loadMedicationHistory();
    // Now that both are loaded, generate heat map
    await loadHeatMapData();
    setState(() => _isLoading = false);
  }

  Future<void> loadPrescriptions() async {
    List<Medication> todaysMedications = [];
    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');
    if (listString != null) {
      final List decoded = jsonDecode(listString);
      final List<Prescription> loaded =
          decoded.map((e) => Prescription.fromJson(e)).toList();
      
      // Store all prescriptions
      setState(() {
        _prescriptions = loaded;
        if (loaded.isNotEmpty) {
          _selectedPrescription = loaded[0]; // Select first prescription by default
        }
      });

      // Get today's date in string format (e.g., 17/04/2025)
      final String today = _formatDate(DateTime.now());
      // Collect today's medications
      for (final prescription in loaded) {
        if(prescription.medications.isNotEmpty){
          for (final med in prescription.medications) {
            if (med.remainderDates.contains(today)) {
              todaysMedications.add(med);
            }
          }
        }
      }

      // Cancel all existing notifications before scheduling new ones
      await _cancelAllNotifications();
      
      // After loading today's medications, schedule notifications
      for (final medication in todaysMedications) {
        _scheduleNotificationsForMedication(medication);
      }

      setState(() {
        _todaysMedications = todaysMedications;
      });
    }
  }

  Future<void> loadMedicationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('history');
    if (historyString != null) {
      final List decoded = jsonDecode(historyString);
      setState(() {
        _medicationHistory = decoded
            .map((e) => EnhancedMedicationHistory.fromJson(e))
            .toList();
      });
    }
  }

  Future<void> saveMedicationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _medicationHistory.map((h) => h.toJson()).toList();
    await prefs.setString('history', jsonEncode(encoded));
  }

  Future<void> loadHeatMapData() async {
    if (_selectedPrescription != null) {
      final dataset = await _generateHeatMapDataset();
      setState(() {
        _heatMapDataset = dataset;
      });
    }
  }


  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); // e.g., 08:00 AM
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
       appBar: AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        'MedTrack',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
         actions: [
           IconButton(
             icon: const Icon(Icons.notifications_outlined,color: Colors.white),
             onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_)=>NotificationScreen(),),);
               // Handle notifications
             },
           ),
         ],
    ),

      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Medications Section
            Text(
              localizations.todaysMedications,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _todaysMedications.length,
              itemBuilder: (context, index) {
                final medication = _todaysMedications[index];
                return _buildMedicationCard(
                  medication: medication,
                );

              },
            ),


            const SizedBox(height: 16),

            // Medication Dosage Chart
            Row(
              children: [
                Text(
                  localizations.dosageMonitor,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(width: 10,),
                Expanded(


                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Prescription>(
                      isExpanded: true,
                      value: _selectedPrescription,
                      hint: Text(localizations.rx),
                      items: _prescriptions.map((prescription) {
                        return DropdownMenuItem<Prescription>(
                          value: prescription,
                          child: Text('${prescription.doctor}'),
                        );
                      }).toList(),
                      onChanged: (Prescription? newValue) {
                        setState(() {
                          _selectedPrescription = newValue;
                        });
                        loadHeatMapData(); // Reload heat map when prescription changes
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            HeatMapCalendar(
              defaultColor: Colors.grey[200],
              flexible: true,
              colorMode: ColorMode.color,
              datasets: _heatMapDataset,
              colorsets: const {

                1: Colors.red,  // Red for missed
                2: Colors.yellow, // Yellow for partially taken
                3: Colors.green, // Green for all taken
              },
              onClick: (value) {
                _showMedicationDetails(value, context);
              },
              textColor: Color(0xFF1A1A1A)
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard({

    required Medication medication,
  }) {
    final localizations = AppLocalizations.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
             "${medication.name}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            Text('${localizations.notes}: ${medication.notes}',
              style: const TextStyle(
                fontSize: 14,
              ),),
            const SizedBox(height: 3),
            // Display status for each reminder time
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medication.reminderTimes.length,
              itemBuilder: (context, index) {
                final time = _formatTimeOfDay(medication.reminderTimes[index]);
                return Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${localizations.schedule}: $time'),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            medication.isTaken[index] = !medication.isTaken[index];
                          });


                          await updateMedicationStatus(
                            medicationId: medication.id,
                            timeIndex: index,
                            isTaken: medication.isTaken[index]
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: medication.isTaken[index] ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            medication.isTaken[index] ? localizations.save : 'Pending',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
Future<void> updateMedicationStatus({
  required String medicationId,
  required int timeIndex,
  required bool isTaken,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final String? prescriptionsString = prefs.getString('prescriptions');
  
  if (prescriptionsString != null) {
    final List decoded = jsonDecode(prescriptionsString);
    final List<Prescription> prescriptions = decoded.map((e) => Prescription.fromJson(e)).toList();
    
    // Update the status in today's medications list for UI
    for (var item in _todaysMedications) {
      if (item.id == medicationId) {
        if (timeIndex < item.isTaken.length) {
          // Check if the status is changing from not taken to taken
          bool wasPreviouslyTaken = item.isTaken[timeIndex];
          item.isTaken[timeIndex] = isTaken;
          
          // Update stock only when medication is marked as taken
          if (!wasPreviouslyTaken && isTaken && item.stock != null) {
            item.stock = item.stock - 1;
          }
          // If medication is unmarked as taken, increment the stock back
          else if (wasPreviouslyTaken && !isTaken && item.stock != null) {
            item.stock = item.stock + 1;
          }
          
          // Update or create history entry
          final String today = _formatDate(DateTime.now());
          final prescription = prescriptions.firstWhere(
            (p) => p.medications.any((m) => m.id == medicationId)
          );
          
          // Create or update history entry
          EnhancedMedicationHistory historyEntry = EnhancedMedicationHistory(
            prescriptionId: prescription.uid,
            prescriptionName: "Prescription ${prescription.medicationTo}",
            date: today,
            medicationName: item.name,
            dosage: item.timesPerDay.toString(),
            notes: item.notes!,
            medicationTimes: item.reminderTimes.map((t) => _formatTimeOfDay(t)).toList(),
            isTaken: item.isTaken,
            doctorName: prescription.doctor,
            patientName: prescription.patient,
            patientAge: prescription.age!,
          );
          
          // Update history list
          _medicationHistory.removeWhere((h) => 
            h.prescriptionId == prescription.uid && 
            h.date == today && 
            h.medicationName == item.name
          );
          _medicationHistory.add(historyEntry);
          
          // Save updated history
          await saveMedicationHistory();
        }
        break;
      }
    }
    
    // Update the status and stock in the full prescriptions list
    for (var prescription in prescriptions) {
      for (var medication in prescription.medications) {
        if (medication.id == medicationId) {
          if (timeIndex < medication.isTaken.length) {
            bool wasPreviouslyTaken = medication.isTaken[timeIndex];
            medication.isTaken[timeIndex] = isTaken;
            
            // Update stock in the main prescriptions list
            if (!wasPreviouslyTaken && isTaken && medication.stock != null) {
              medication.stock = medication.stock - 1;
            }
            // If medication is unmarked as taken, increment the stock back
            else if (wasPreviouslyTaken && !isTaken && medication.stock != null) {
              medication.stock = medication.stock + 1;
            }
          }
          break;
        }
      }
    }
    
    // Save the updated full prescriptions list
    final updatedString = jsonEncode(prescriptions.map((e) => e.toJson()).toList());
    await prefs.setString('prescriptions', updatedString);
    // Add this line to update the heat map
    await loadHeatMapData();
  }
}

Future<Map<DateTime, int>> _generateHeatMapDataset() async {
  Map<DateTime, int> dataset = {};

  // Use history data to generate heat map
  for (var history in _medicationHistory) {
    if (_selectedPrescription != null && 
        history.prescriptionId == _selectedPrescription!.uid) {
      final parts = history.date.split('/');
      final date = DateTime(
        int.parse(parts[2]), // year
        int.parse(parts[1]), // month
        int.parse(parts[0]), // day
      );
      
      int totalMeds = history.medicationTimes.length;
      int takenMeds = history.isTaken.where((taken) => taken).length;
      
      if (takenMeds == 0) {
        dataset[date] = 1; // All missed (red)
      } else if (takenMeds < totalMeds) {
        dataset[date] = 2; // Partially taken (yellow)
      } else {
        dataset[date] = 3; // All taken (green)
      }
    }
  }
  return dataset;
}

void _showMedicationDetails(DateTime date, BuildContext context) {
  // Format date to match your storage format
  String formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  
  // Filter medication history for the selected date and prescription
  List<EnhancedMedicationHistory> historyForDate = _medicationHistory.where((history) => 
    history.date == formattedDate && 
    history.prescriptionId == _selectedPrescription?.uid
  ).toList();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Medications for ${DateFormat('MMM d, yyyy').format(date)}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: historyForDate.isEmpty
            ? [Text('No medication records for this date')]
            : historyForDate.map((history) => ListTile(
                title: Text(history.medicationName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doctor: ${history.doctorName}'),
                    Text('Patient: ${history.patientName} (${history.patientAge} years)'),
                    Text('Dosage: ${history.dosage}'),
                    Text('Note: ${history.notes}'),
                  ],
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: history.medicationTimes.asMap().entries.map((entry) => 
                    Text(
                      '${history.medicationTimes[entry.key]}: ${history.isTaken[entry.key] ? "Taken" : "Missed"}',
                      style: TextStyle(
                        color: history.isTaken[entry.key] ? Colors.green : Colors.red,
                      ),
                    )
                  ).toList(),
                ),
              )).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _scheduleNotificationsForMedication(Medication medication) async {
  try {
    final now = DateTime.now();
    final today = _formatDate(now);
    
    // Only schedule notifications if the medication is for today or future dates
    if (!medication.remainderDates.contains(today)) {
      return;
    }
    
    for (int i = 0; i < medication.reminderTimes.length; i++) {
      // Skip scheduling if medication is already taken for this time
      if (medication.isTaken[i]) {
        continue;
      }
      
      final reminderTime = medication.reminderTimes[i];
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime.hour,
        reminderTime.minute,
      );
      
      // Only schedule if the time hasn't passed yet
      if (!scheduledTime.isBefore(now)) {
        // Create a unique notification channel ID for each medication
        String channelId = 'medication_channel_${medication.id}';
        
        final androidDetails = AndroidNotificationDetails(
          channelId,
          'Medication Reminders',
          channelDescription: 'Notifications for medication reminders',
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
          enableLights: true,
          playSound: true,
          color: Colors.blue,
          ledColor: Colors.blue,
          ledOnMs: 1000,
          ledOffMs: 500,
          icon: 'logo',
          channelShowBadge: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          actions: [
            const AndroidNotificationAction('take', 'Take'),
            const AndroidNotificationAction('skip', 'Skip'),
          ],
          ongoing: true,
          autoCancel: false,
          timeoutAfter: 300000, // 5 minutes
        );

        final iOSDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
          categoryIdentifier: 'medication_category',
          threadIdentifier: channelId,
        );

        final notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iOSDetails,
        );

        await flutterLocalNotificationsPlugin.zonedSchedule(
          medication.id.hashCode + i,
          'Medication Reminder',
          'Time to take ${medication.name}${medication.notes != null ? "\nNotes: ${medication.notes}" : ""}',
          tz.TZDateTime.from(scheduledTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'medication_${medication.id}_$i',
        );
        
        print('Scheduled notification for ${medication.name} at ${scheduledTime.toString()}');
        print('Channel ID: $channelId');
        print('Notification ID: ${medication.id.hashCode + i}');
      }
    }
  } catch (e, stackTrace) {
    print('Error scheduling notification: $e');
    print('Stack trace: $stackTrace');
  }
}
}