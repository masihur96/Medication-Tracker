import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/screens/add_medication_screen.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:med_track/utils/bounching_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/custom_size.dart';

class NewRxScreen extends StatefulWidget {
  final Prescription? prescription;
  const NewRxScreen({super.key, this.prescription});

  @override
  State<NewRxScreen> createState() => _NewRxScreenState();
}

class _NewRxScreenState extends State<NewRxScreen> {
  final _formKey = GlobalKey<FormState>();

  final _doctorController = TextEditingController();

  final _patientController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing prescription data if available
    if (widget.prescription != null) {
      _doctorController.text = widget.prescription!.doctor;
      _patientController.text = widget.prescription!.patient;
      _ageController.text = widget.prescription!.age?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _doctorController.dispose();

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


              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            "Rx",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "24 Aug 2025",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          decoration: InputDecoration(
                            labelText: localizations.age,
                            icon: Icon(Icons.date_range),
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
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

                      // _buildLineField(label: '${localizations.for_}: ${widget.prescription.medicationTo}', size: 12),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(child: Divider(thickness: 1, color: Colors.black87)),
                      IconButton(onPressed: (){

    if (_formKey.currentState!.validate()) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => BounchingDialog(
            width: screenSize(context, 0.6),
            child: AddMedicationScreen(prescription: Prescription(uid: DateTime.now().microsecondsSinceEpoch.toString(), doctor: _doctorController.text,
                date: DateTime.now().toString(), patient: _patientController.text, age: int.parse(_ageController.text), medications: []))),
      );

    }





                      }, icon: Icon(Icons.add_circle_outlined))
                    ],
                  ),
                ],
              ),




              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final prescription = Prescription(

                      uid: widget.prescription?.uid ?? 
                           DateTime.now().microsecondsSinceEpoch.toString(),
                      doctor: _doctorController.text,
                      date: DateTime.now().toString(),

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