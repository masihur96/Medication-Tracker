import 'package:flutter/material.dart';
import 'package:med_track/models/medication.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;

  const MedicationCard({required this.medication});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(medication.name, style: TextStyle(fontSize: 20)),
            Text('Dosage: ${medication.timesPerDay}'),
            Text('Times: ${medication.timesPerDay}'),
            // Add more details
          ],
        ),
      ),
    );
  }
}