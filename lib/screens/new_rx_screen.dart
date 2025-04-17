import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:med_track/models/prescription.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewRxScreen extends StatefulWidget {
  const NewRxScreen({super.key});

  @override
  State<NewRxScreen> createState() => _NewRxScreenState();
}

class _NewRxScreenState extends State<NewRxScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _doctorController = TextEditingController();
  final _dateController = TextEditingController();
  final _chamberController = TextEditingController();
  final _patientController = TextEditingController();

  @override
  void dispose() {
    _medicationController.dispose();
    _doctorController.dispose();
    _dateController.dispose();
    _chamberController.dispose();
    _patientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prescription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name',
                  icon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter doctor name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _chamberController,
                decoration: const InputDecoration(
                  labelText: 'Chamber Name',
                  icon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter chamber name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patientController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  icon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicationController,
                decoration: const InputDecoration(
                  labelText: 'Medication To',
                  icon: Icon(Icons.medication),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medication title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Prescription Date',
                  icon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _dateController.text = "${picked.day}/${picked.month}/${picked.year}";



                    });
                  }
                },
                validator: (value) {
                  if (_dateController.text.isEmpty) {
                    return 'Please select prescription date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {

                    savePrescription(Prescription(
                        medicationTo: _medicationController.text,
                        uid: DateTime.now().microsecondsSinceEpoch.toString(),
                        doctor: _doctorController.text,
                        date: _dateController.text,
                        chamber: _chamberController.text,
                        patient: _patientController.text,
                        medications: []
                    ),
                    );

                    
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Prescription'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> savePrescription(Prescription newPrescription) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing list
    final String? existingListString = prefs.getString('prescriptions');
    List<Prescription> prescriptions = [];

    if (existingListString != null) {
      final List decodedList = jsonDecode(existingListString);
      prescriptions = decodedList.map((e) => Prescription.fromJson(e)).toList();
    }

    // Add new prescription
    prescriptions.add(newPrescription);

    // Save updated list
    final String encodedList =
    jsonEncode(prescriptions.map((e) => e.toJson()).toList());
    await prefs.setString('prescriptions', encodedList);
  }
} 