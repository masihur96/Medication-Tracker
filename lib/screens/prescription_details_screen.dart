import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/screens/new_rx_screen.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_medication_screen.dart';

class PrescriptionDetailsScreen extends StatefulWidget {
  final Prescription prescription;

  const PrescriptionDetailsScreen({
    super.key,
    required this.prescription,
  });

  @override
  State<PrescriptionDetailsScreen> createState() => _PrescriptionDetailsScreenState();
}

class _PrescriptionDetailsScreenState extends State<PrescriptionDetailsScreen> {
  late Prescription prescription;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    prescription = widget.prescription;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          localizations.prescriptions,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>NewRxScreen(prescription: prescription,uuid: "",),),);
          }, icon: Icon(Icons.edit_outlined))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rx Text on Left
                        Column(
                          children: [
                            Text(
                              "Rx",
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildLineField(label: prescription.date,size: 16),
                          ],
                        ),
                        SizedBox(width: 16),
                        // Patient Info on Right
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLineField(label: '${localizations.doctor}: ${prescription.doctor}',size: 16),
                              // _buildLineField(label: '${localizations.chamber}: ${prescription.chamber}',size: 12),
                
                              Divider(
                              ),
                              SizedBox(height: 5,),
                              _buildLineField(label: '${localizations.patient}: ${prescription.patient}',size: 14),
                              SizedBox(height: 5,),
                              _buildLineField(label: '${localizations.age}: ${prescription.age}',size: 14),
                              // _buildLineField(label: '${localizations.for_}: ${prescription.medicationTo}', size: 12),
                
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(thickness: 1, color: Colors.black87),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              localizations.medications,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    if (_isEditing)
                      const DataColumn(label: Text('')),
                    DataColumn(label: Text(localizations.name)),
                    // DataColumn(label: Text(localizations.dosage)),
                    DataColumn(label: Text(localizations.frequency)),
                    DataColumn(label: Text(localizations.timesPerDay)),
                    DataColumn(label: Text(localizations.stock)),
                    DataColumn(label: Text(localizations.notes)),
                    DataColumn(label: Text(localizations.reminderTimes)),
                  ],
                  rows: prescription.medications.map((med) {
                    return DataRow(cells: [
                      if (_isEditing)
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddMedicationScreen(
                                    prescription: prescription,
                                    medication: med,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      DataCell(
                        Row(
                          children: [
                            if (med.stock <= 3) // Assuming 5 or less is considered low stock
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ),
                            Text(
                              med.name,
                              style: TextStyle(
                                color: med.stock <= 3 ? Colors.red : null,
                                fontWeight: med.stock <= 3 ? FontWeight.bold : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // DataCell(Text(med.dosage)),
                      DataCell(Text(med.frequency)),
                      DataCell(Text(med.timesPerDay.toString())),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: med.stock <= 5 ? Colors.red.withOpacity(0.1) : null,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            med.stock.toString(),
                            style: TextStyle(
                              color: med.stock <= 5 ? Colors.red : null,
                              fontWeight: med.stock <= 5 ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(med.notes ?? '')),
                      DataCell(
                        Wrap(
                          children: med.reminderTimes.map((time) {

                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Chip(
                                label: Text(formatTimeOfDay(context,time)),
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineField({required String label,required double size}) {
    return Text(
      label,
      style: TextStyle(fontSize: size, fontWeight: FontWeight.w500),
    );
  }

  String formatTimeOfDay(BuildContext context, TimeOfDay time) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
  }


  Future<void> updatePrescription(Prescription updatedPrescription) async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing prescriptions
    final String? data = prefs.getString('prescriptions');
    if (data == null) return;

    final List<dynamic> decodedList = jsonDecode(data);
    List<Prescription> prescriptions = decodedList
        .map((e) => Prescription.fromJson(e as Map<String, dynamic>))
        .toList();

    // Find and update the prescription by UID
    final index = prescriptions.indexWhere((p) => p.uid == updatedPrescription.uid);
    if (index != -1) {
      prescriptions[index] = updatedPrescription;

      // Save updated list
      final String updatedData = jsonEncode(prescriptions.map((e) => e.toJson()).toList());
      await prefs.setString('prescriptions', updatedData);
    }
  }

} 