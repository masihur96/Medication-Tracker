import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/screens/new_rx_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrescriptionDetailsScreen extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionDetailsScreen({
    super.key,
    required this.prescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Prescription Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
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
                              'Rx',
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
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
                              _buildLineField(label: 'DR: ${prescription.doctor}',size: 16),
                              // SizedBox(height: 12),
                              _buildLineField(label: 'Ch: ${prescription.chamber}',size: 12),
                
                              Divider(
                              ),
                              _buildLineField(label: 'Patient: ${prescription.patient}',size: 16),
                              _buildLineField(label: 'For: ${prescription.medicationTo}',size: 12),
                
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(thickness: 1, color: Colors.black87),
                  ],
                ),
                Positioned(
                  right: -10,
                  top: -10,
                  child: IconButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>NewRxScreen(prescription: prescription,),),);
                  }, icon: Icon(Icons.edit_outlined),),),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              'Medications',
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
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Dosage')),
                    DataColumn(label: Text('Frequency')),
                    DataColumn(label: Text('Times/Day')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Notes')),
                    DataColumn(label: Text('Reminder Times')),
                  ],
                  rows: prescription.medications.map((med) {


                    return DataRow(cells: [
                      DataCell(Text(med.name)),
                      DataCell(Text(med.dosage)),
                      DataCell(Text(med.frequency)),
                      DataCell(Text(med.timesPerDay.toString())),
                      DataCell(Text(med.stock.toString())),
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