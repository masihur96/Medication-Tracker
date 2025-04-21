import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewRxScreen extends StatefulWidget {
  final Prescription? prescription;
  const NewRxScreen({super.key, this.prescription});

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
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing prescription data if available
    if (widget.prescription != null) {
      _medicationController.text = widget.prescription!.medicationTo;
      _doctorController.text = widget.prescription!.doctor;
      _dateController.text = widget.prescription!.date;
      _chamberController.text = widget.prescription!.chamber;
      _patientController.text = widget.prescription!.patient;
      _ageController.text = widget.prescription!.age?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _medicationController.dispose();
    _doctorController.dispose();
    _dateController.dispose();
    _chamberController.dispose();
    _patientController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          widget.prescription == null ? localizations.addPrescription : localizations.prescriptionDetails,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _doctorController,
                decoration: InputDecoration(
                  labelText: localizations.doctor,
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
                decoration: InputDecoration(
                  labelText: localizations.chamber,
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
                decoration: InputDecoration(
                  labelText: localizations.patient,
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
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: localizations.age,
                  icon: Icon(Icons.calendar_view_day),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicationController,
                decoration: InputDecoration(
                  labelText: localizations.medicationName,
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
                decoration: InputDecoration(
                  labelText: localizations.date,
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
                    final prescription = Prescription(
                      medicationTo: _medicationController.text,
                      uid: widget.prescription?.uid ?? 
                           DateTime.now().microsecondsSinceEpoch.toString(),
                      doctor: _doctorController.text,
                      date: _dateController.text,
                      chamber: _chamberController.text,
                      patient: _patientController.text,
                      age: int.parse(_ageController.text),
                      medications: widget.prescription?.medications ?? [],
                    );

                    savePrescription(prescription);
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.prescription == null ? localizations.save : localizations.edit),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> savePrescription(Prescription prescription) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing list
    final String? existingListString = prefs.getString('prescriptions');
    List<Prescription> prescriptions = [];

    if (existingListString != null) {
      final List decodedList = jsonDecode(existingListString);
      prescriptions = decodedList.map((e) => Prescription.fromJson(e)).toList();
    }

    // If editing, remove the old prescription
    if (widget.prescription != null) {
      prescriptions.removeWhere((p) => p.uid == widget.prescription!.uid);
    }

    // Add the prescription (new or updated)
    prescriptions.add(prescription);

    // Save updated list
    final String encodedList =
        jsonEncode(prescriptions.map((e) => e.toJson()).toList());
    await prefs.setString('prescriptions', encodedList);
  }
} 