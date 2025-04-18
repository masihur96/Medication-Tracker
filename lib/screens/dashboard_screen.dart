import 'dart:convert';
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
  List<MedicationHistory> _medicationHistory = [];

  bool _isLoading = true;

  @override
  void initState() {

    loadPrescriptions();
    // TODO: implement initState
    super.initState();
  }
  Future<void> loadPrescriptions() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');
    if (listString != null) {
      final List decoded = jsonDecode(listString);
      final List<Prescription> loaded =
      decoded.map((e) => Prescription.fromJson(e)).toList();
      // Get today's date in string format (e.g., 17/04/2025)
      final String today = _formatDate(DateTime.now());
      // Collect today's medications
      List<Medication> todaysMedications = [];
      for (final prescription in loaded) {
        for (final med in prescription.medications) {
          if (med.remainderDates.contains(today)) {
            todaysMedications.add(med);
          }
        }
      }
      setState(() {
        _todaysMedications = todaysMedications; // You need this list in your state
        // List<Prescription> _prescriptions  = loaded;
        _isLoading = false;
      });

      medicationHistory(todayMedications: _todaysMedications);
// Then you can store or display these history entries


    } else {
      setState(() => _isLoading = false);
    }
  }


  Future<void> saveHistoryList(List<MedicationHistory> historyList) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = historyList.map((h) => h.toJson()).toList();
    await prefs.setString('medicationHistory', jsonEncode(encoded));
    _medicationHistory =   await loadHistoryList();
  }

  Future<List<MedicationHistory>> loadHistoryList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('medicationHistory');
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      return decoded.map((e) => MedicationHistory.fromJson(e)).toList();
    }
    return [];
  }

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
    saveHistoryList(historyList);
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
              itemCount: _medicationHistory.length,
              itemBuilder: (context, index) {
                final history = _medicationHistory[index];

                return  _buildMedicationCard(
                  // name: history.medicationName,
                  // time: history.time,
                  // dosage: history.dosage,
                  // status:  history.isTaken ? 'Taken' : 'Pending',
                  medicationHistory: history,
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
    // required String name,
    // required String time,
    // required String dosage,
    // required String status,
    required MedicationHistory medicationHistory,
  }) {





    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  medicationHistory.medicationName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () async{
                    setState(() {

                      if (!medicationHistory.isTaken) {
                        medicationHistory.isTaken = true;
                      } else {
                        medicationHistory.isTaken = false; // Optional: toggle back
                      }
                    });


                    setState(() {}); // Refresh the UI if needed

                    await updateMedicationStatus(
                        medicationId: medicationHistory.medicationId,

                        isTaken: medicationHistory.isTaken
                    );


                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: medicationHistory.isTaken ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      medicationHistory.isTaken ? 'Taken' : 'Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Time: ${medicationHistory.time}'),
            Text('Dosage: ${medicationHistory.dosage}'),
          ],
        ),
      ),
    );
  }

  Future<void> updateMedicationStatus({
    required String medicationId,
    required bool isTaken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('medication_history');
    print(historyString);
    print(isTaken);
    if (historyString != null) {
      final List decoded = jsonDecode(historyString);
      List<MedicationHistory> historyList = decoded
          .map((e) => MedicationHistory.fromJson(e))
          .toList();

      print(isTaken);
      // 🔍 Find and update the matching record
      for (var item in historyList) {
        if (item.medicationId == medicationId) {
          item.isTaken = isTaken;
          break;
        }
      }

      // 💾 Save the updated list
      final updatedString = jsonEncode(historyList.map((e) => e.toJson()).toList());
      await prefs.setString('medication_history', updatedString);

      // Optional: Update UI
      _medicationHistory = historyList;
    }
  }

}