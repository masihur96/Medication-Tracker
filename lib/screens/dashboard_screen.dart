import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/screens/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_history.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Medication> _todaysMedications = [];
  // List<MedicationHistory> _medicationHistory = [];

  bool _isLoading = true;

  @override
  void initState() {

    loadPrescriptions();
     // loadHistoryList();
    // TODO: implement initState
    super.initState();
  }

  Future<void> loadPrescriptions() async {
    setState(() => _isLoading = true);
    List<Medication> todaysMedications = [];
    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');
    if (listString != null) {
      final List decoded = jsonDecode(listString);
      final List<Prescription> loaded =
      decoded.map((e) => Prescription.fromJson(e)).toList();
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
      setState(() {
        _todaysMedications = todaysMedications; // You need this list in your state
        // List<Prescription> _prescriptions  = loaded;
        _isLoading = false;
      });

    //  medicationHistory(todayMedications: _todaysMedications);
// Then you can store or display these history entries


    } else {
      setState(() => _isLoading = false);
    }
  }


  // Future<void> saveHistoryList(List<MedicationHistory> historyList) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final encoded = historyList.map((h) => h.toJson()).toList();
  //   await prefs.setString('medicationHistory', jsonEncode(encoded));
  //   _medicationHistory =   await loadHistoryList();
  // }
  //
  // Future<List<MedicationHistory>> loadHistoryList() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final jsonString = prefs.getString('medicationHistory');
  //   if (jsonString != null) {
  //     final List decoded = jsonDecode(jsonString);
  //     return decoded.map((e) => MedicationHistory.fromJson(e)).toList();
  //   }
  //   return [];
  // }

  List<MedicationHistory> medicationHistory({required List<Medication> todayMedications}) {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<MedicationHistory> historyList = [];

    for (Medication m in todayMedications) {
      for (TimeOfDay timeOfDay in m.reminderTimes) {
        final String time = _formatTimeOfDay(timeOfDay);
        historyList.add(
          MedicationHistory(
            medicationId: m.id,
            medicationName: m.name,
            dosage: m.dosage,
            date: today,
            time: time,
            isTaken: false,
          ),
        );
      }
    }
   // saveHistoryList(historyList);
    return historyList;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_)=>NotificationScreen(),),);
              // Handle notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Medications Section
            const Text(
              "Today's Medications",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _todaysMedications.length,
              itemBuilder: (context, index) {
                final medication = _todaysMedications[index];
                return  _buildMedicationCard(
                  medication: medication,
                );

              },
            ),


            const SizedBox(height: 24),
            
            // Medication Dosage Chart
            const Text(
              'Medication Dosage Trend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            HeatMapCalendar(
              defaultColor: Colors.white,
              flexible: true,
              colorMode: ColorMode.color,
              datasets: {
                DateTime(2025, 4, 6): 1,
                DateTime(2025, 4, 7): 2,
                DateTime(2025, 4, 8): 3,
                DateTime(2025, 4, 9): 1,
                DateTime(2025, 4, 13): 2,
              },
              colorsets: const {
                1: Colors.red,
                2: Colors.orange,
                3: Colors.green,
              },
              onClick: (value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.toString())));
              },
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
             "${medication.name} (${medication.dosage}) ",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            Text('Note: ${medication.notes}',
              style: const TextStyle(
                fontSize: 14,
              ),),
            const SizedBox(height: 3),
            // Display status for each reminder time
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: medication.reminderTimes.length,
              itemBuilder: (context, index) {
                final time = _formatTimeOfDay(medication.reminderTimes[index]);
                return Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Time: $time'),
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
                            medication.isTaken[index] ? 'Taken' : 'Pending',
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
          item.isTaken[timeIndex] = isTaken;
        }
        break;
      }
    }
    
    // Update the status in the full prescriptions list
    for (var prescription in prescriptions) {
      for (var medication in prescription.medications) {
        if (medication.id == medicationId) {
          if (timeIndex < medication.isTaken.length) {
            medication.isTaken[timeIndex] = isTaken;
          }
          break;
        }
      }
    }
    
    // Save the updated full prescriptions list
    final updatedString = jsonEncode(prescriptions.map((e) => e.toJson()).toList());
    await prefs.setString('prescriptions', updatedString);
  }
}
}