import 'package:flutter/material.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class AddMedicationScreen extends StatefulWidget {
  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  List<int> _selectedTimes = [];

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final newMed = Medication(
        id: DateTime.now().toString(),
        name: _nameController.text,
        dosage: _dosageController.text,
        timesPerDay: _selectedTimes,
      );
      Provider.of<MedicationProvider>(context, listen: false).addMedication(newMed);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Medication')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Medication Name'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            // Add more fields for dosage, times etc.
            ElevatedButton(
              onPressed: _saveMedication,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}