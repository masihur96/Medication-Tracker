import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_track/utils/app_localizations.dart';

import 'add_medication_screen.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, bool> _alarmStates = {};  // To track alarm states for each medication


  List<Prescription> _prescriptions = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    loadPrescriptions();
  }

  Future<void> loadPrescriptions() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');
    print(listString);
    if (listString != null) {
      final List decoded = jsonDecode(listString);
      final List<Prescription> loaded =
      decoded.map((e) => Prescription.fromJson(e)).toList();
      setState(() {
        _prescriptions = loaded;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          localizations.medications,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),

        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: localizations.drugs),
            Tab(text: localizations.stock),
            Tab(text: localizations.active),
            Tab(text: localizations.inactive),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMedicationList(),
          _buildAvailableStock(),
          _buildActiveMedications(),
          _buildInactiveMedications(),
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    final localizations = AppLocalizations.of(context);
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_prescriptions.isEmpty) {
      return Center(child: Text(localizations.noMedicationsYet));
    }

    // Flatten all medications from all prescriptions
    List<Medication> allMedications = [];
    for (var prescription in _prescriptions) {
      allMedications.addAll(prescription.medications);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: allMedications.length,
      itemBuilder: (context, index) {
        final medication = allMedications[index];
        return _buildMedicationItem(
          name: medication.name,
          dosage: medication.timesPerDay.toString(),
          frequency: medication.frequency,
          timeOfDay: medication.reminderTimes.isEmpty 
              ? localizations.notSet
              : medication.reminderTimes
                  .map((time) => _timeOfDayToString(time))
                  .join(', '),
          notes: medication.notes ?? localizations.noMedicationsYet,
        );
      },
    );
  }

  Widget _buildAvailableStock() {
    final localizations = AppLocalizations.of(context);
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Medication> allMedications = [];
    for (var prescription in _prescriptions) {
      allMedications.addAll(prescription.medications);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: allMedications.length,
      itemBuilder: (context, index) {
        final medication = allMedications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            title: Text(medication.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${localizations.currentStock}: ${medication.stock} ${localizations.units}'),
                // Note: Add expiry date if you add it to the Medication model
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveMedications() {
    final localizations = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Medication> activeMedications = [];
    for (var prescription in _prescriptions) {
      activeMedications.addAll(
        prescription.medications.where((med) => med.isActive)
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: activeMedications.length,
      itemBuilder: (context, index) {
        final medication = activeMedications[index];
        return _buildMedicationItem(
          name: medication.name,
          dosage: medication.timesPerDay.toString(),
          frequency: medication.frequency,
          timeOfDay: medication.reminderTimes.isEmpty
              ? localizations.notSet
              : medication.reminderTimes
                  .map((time) => _timeOfDayToString(time))
                  .join(', '),
          notes: medication.notes ?? localizations.noMedicationsYet,
        );
      },
    );
  }

  Widget _buildInactiveMedications() {
    final localizations = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Medication> inactiveMedications = [];
    for (var prescription in _prescriptions) {
      inactiveMedications.addAll(
        prescription.medications.where((med) => !med.isActive)
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: inactiveMedications.length,
      itemBuilder: (context, index) {
        final medication = inactiveMedications[index];
        return _buildMedicationItem(
          name: medication.name,
          dosage: medication.timesPerDay.toString(),
          frequency: localizations.notTaking,
          timeOfDay: 'N/A',
          notes: medication.notes ?? localizations.discontinued,
        );
      },
    );
  }

  String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  Widget _buildMedicationItem({
    required String name,
    required String dosage,
    required String frequency,
    required String timeOfDay,
    required String notes,
  }) {
    final localizations = AppLocalizations.of(context);
    
    // Initialize alarm state for this medication if not exists
    _alarmStates[name] ??= false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        children: [
          Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.medication, size: 16),
                        const SizedBox(width: 8),
                        Text('${localizations.dosage}: $dosage'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text('${localizations.frequency}: $frequency'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: timeOfDay == localizations.notSet || timeOfDay == 'N/A'
                                ? [Text('${localizations.time}: $timeOfDay')]
                                : [
                              for (int i = 0; i < timeOfDay.split(', ').length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    i == timeOfDay.split(', ').length - 1
                                        ? timeOfDay.split(', ')[i]
                                        : '${timeOfDay.split(', ')[i]} - ',
                                  ),
                                )
                            ],
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.note, size: 16),
                        const SizedBox(width: 8),
                        Text('${localizations.notes}: $notes'),
                      ],
                    ),
                  ],
                ),

              ),
            ],
          ),
          // New alarm control positioned at top right
          if (frequency != localizations.notTaking)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _alarmStates[name] = !(_alarmStates[name] ?? false);
                  });
                  
                  if (_alarmStates[name]!) {
                    // Alarm is turned ON
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Alarm enabled for $name'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    // TODO: Add your alarm setup logic here
                  } else {
                    // Alarm is turned OFF
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Alarm disabled for $name'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    // TODO: Add your alarm cancellation logic
                  }
                },
                icon: Icon(
                  _alarmStates[name]! ? Icons.alarm_on : Icons.alarm_off,
                  size: 20,
                  color: _alarmStates[name]! ? Colors.blue : Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 