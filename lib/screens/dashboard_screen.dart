import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';

import 'package:med_track/screens/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Medication> _todaysMedications = [];

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
    } else {
      setState(() => _isLoading = false);
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
            Column(
              children: _todaysMedications.expand((medication) {
                return medication.reminderTimes.map((timeOfDay) {
                  return Column(
                    children: [
                      _buildMedicationCard(
                        name: medication.name,
                        time: _formatTimeOfDay(timeOfDay),
                        dosage: medication.dosage,
                        status: 'Pending', // You can customize this based on logic
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList();
              }).toList(),
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

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildMedicationCard({
    required String name,
    required String time,
    required String dosage,
    required String status,
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
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Taken' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Time: $time'),
            Text('Dosage: $dosage'),
          ],
        ),
      ),
    );
  }
}