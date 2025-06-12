import 'dart:convert';
import 'dart:developer';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:med_track/utils/bounching_dialog.dart';
import 'package:med_track/utils/custom_size.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_medication_history.dart';
import 'ai_doctor_chat_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Medication> _todayMedications = [];
  Map<DateTime, int> _heatMapDataset = {};
  List<Prescription> _prescriptions = [];
  Prescription? _selectedPrescription;
  List<EnhancedMedicationHistory> _medicationHistory = [];
  bool _isLoading = true;

  
  @override
  void initState() {
    super.initState();
    initTask();
    // Initialize data

  }

  initTask()async{
   await initializeData();

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
    try {
      List<Medication> todayMedications = [];
      final prefs = await SharedPreferences.getInstance();
      final String? listString = prefs.getString('prescriptions');
      if (listString != null) {
        final List decoded = jsonDecode(listString);
        final List<Prescription> loaded =
            decoded.map((e) => Prescription.fromJson(e)).toList();
        setState(() {
          _prescriptions = loaded;
          if (loaded.isNotEmpty) {
            _selectedPrescription = loaded[0];
          }
        });

        final String today = _formatDate(DateTime.now());

        // Collect today's medications and schedule notifications
        for (final prescription in loaded) {
          if(prescription.medications.isNotEmpty){
            for (final med in prescription.medications) {
              // Create a list to store all scheduled DateTimes

              if (med.remainderDates.contains(today)) {
                todayMedications.add(med);
              }
            }
          }
        }

        setState(() {
          _todayMedications = todayMedications;
        });

      }
    } catch (e, stackTrace) {
      log('Error loading prescriptions: $e');
      log('Stack trace: $stackTrace');
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
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
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
              itemCount: _todayMedications.length,
              itemBuilder: (context, index) {
                final medication = _todayMedications[index];
                return GestureDetector(
                  onTap: (){
                    print(medication.audioFilePath);

                  },
                  child: _buildMedicationCard(
                    medication: medication,
                  ),
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
                          child: Text(prescription.doctor),
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
      floatingActionButton:DraggableFab(
        child: FloatingActionButton(
          onPressed: () {
            _showAIDoctorDialog(context,localizations);
          }
          ,
          child: Icon(Icons.local_hospital, color: Colors.black, size: 30),
        ),
      )
    );
  }

  void _showAIDoctorDialog(BuildContext context,AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => BounchingDialog(
        height: screenSize(context, 1.0),

          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [


             Text(
              localizations.aiDoctorTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
              Image.asset('assets/doctor.png', height: 100, width: 100,fit: BoxFit.fill,),
                    Text(
            "${localizations.aiDoctorGreeting}\n\n"
                "${localizations.aiDoctorOption}\n\n"
                "${localizations.aiDoctorPrompt}",
                    ),


            SizedBox(height: 20),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                  child:  Text(localizations.cancel),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToAIDoctorChat(context);
                  },
                  icon: const Icon(Icons.chat,color: Colors.white,),
                  label:  Text(localizations.startChat),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),

              ],
            ),

                  ],),
          ))
    );
  }
  void _navigateToAIDoctorChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MedicationChatScreen()),
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
             medication.name,
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
                      Text('${localizations.time}: $time'),
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
    for (var item in _todayMedications) {
      if (item.id == medicationId) {
        if (timeIndex < item.isTaken.length) {
          // Check if the status is changing from not taken to taken
          bool wasPreviouslyTaken = item.isTaken[timeIndex];
          item.isTaken[timeIndex] = isTaken;
          
          // Update stock only when medication is marked as taken
          if (!wasPreviouslyTaken && isTaken) {
            item.stock = item.stock - 1;
          }
          // If medication is unmarked as taken, increment the stock back
          else if (wasPreviouslyTaken && !isTaken) {
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
            if (!wasPreviouslyTaken && isTaken) {
              medication.stock = medication.stock - 1;
            }
            // If medication is unmarked as taken, increment the stock back
            else if (wasPreviouslyTaken && !isTaken) {
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

  // Group history entries by date
  Map<String, List<EnhancedMedicationHistory>> historyByDate = {};
  
  for (var history in _medicationHistory) {
    if (_selectedPrescription != null && 
        history.prescriptionId == _selectedPrescription!.uid) {
      if (!historyByDate.containsKey(history.date)) {
        historyByDate[history.date] = [];
      }
      historyByDate[history.date]!.add(history);
    }
  }

  // Process each date's medications
  historyByDate.forEach((dateStr, histories) {
    final parts = dateStr.split('/');
    final date = DateTime(
      int.parse(parts[2]), // year
      int.parse(parts[1]), // month
      int.parse(parts[0]), // day
    );

    int totalMedications = 0;
    int takenMedications = 0;

    // Count total medications and taken medications for the day
    for (var history in histories) {
      totalMedications += history.medicationTimes.length;
      takenMedications += history.isTaken.where((taken) => taken).length;
    }

    // Determine color based on overall medication adherence for the day
    if (totalMedications == 0) {
      dataset[date] = 0; // No medications scheduled
    } else if (takenMedications == 0) {
      dataset[date] = 1; // All missed (red)
    } else if (takenMedications < totalMedications) {
      dataset[date] = 2; // Partially taken (yellow)
    } else {
      dataset[date] = 3; // All taken (green)
    }
  });

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
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: historyForDate.isEmpty
                ? [Text('No medication records for this date')]
                : historyForDate.map((history) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side (medication details)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history.medicationName.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text('Dosage: ${history.dosage}'),
                        Text('Note: ${history.notes}'),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  // Right side (medication times and status)
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: history.medicationTimes.asMap().entries.map((entry) =>
                          Text(
                            '  ${entry.value}\n${history.isTaken[entry.key] ? "Taken" : "Missed"}',
                            style: TextStyle(
                              color: history.isTaken[entry.key] ? Colors.green : Colors.red,

                            ),textAlign: TextAlign.center,
                          )
                      ).toList(),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
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


}