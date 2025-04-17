import 'package:flutter/material.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';

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

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_information,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(BuildContext context, Medication medication) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medication,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Dosage', medication.dosage),
            _buildInfoRow('Frequency', medication.frequency),
            _buildInfoRow('Times per Day', medication.timesPerDay.toString()),
            _buildInfoRow('Stock', medication.stock.toString()),
            _buildInfoRow('Notes', medication.notes!),
            const SizedBox(height: 8),
            Text(
              'Reminder Times:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
            ),
            Wrap(
              spacing: 8,
              children: medication.reminderTimes.map((time) {
                return Chip(
                  label: Text(time.toString()),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 