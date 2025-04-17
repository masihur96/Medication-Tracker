import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AddMedicationScreen extends StatefulWidget {
  final Prescription prescription;
  final Medication? medication;

  const AddMedicationScreen({super.key,required this.prescription,this.medication});
  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _stockController = TextEditingController();
  final _noteController = TextEditingController();
  String _frequency = 'Daily'; // Default frequency
  bool _isActive = false;
  int _timesPer = 1; // Default frequency
  final List<TimeOfDay> _selectedTimes = [TimeOfDay.now()]; // Update to list of TimeOfDay

  // List of frequency options
  final List<String> _frequencyOptions = ['Daily', 'Weekly', 'Monthly', 'As needed'];

  @override
  void initState() {
    super.initState();
    // Initialize form fields if medication exists
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _dosageController.text = widget.medication!.dosage;
      _stockController.text = widget.medication!.stock.toString();
      _noteController.text = widget.medication!.notes!;
      _frequency = widget.medication!.frequency;
      _timesPer = widget.medication!.timesPerDay;
      _isActive = widget.medication!.isActive;
      _selectedTimes.clear();
      _selectedTimes.addAll(widget.medication!.reminderTimes);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _stockController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index],
    );
    if (picked != null) {
      setState(() {
        _selectedTimes[index] = picked;
      });
    }
  }

  // Add this method to build time selection fields
  List<Widget> _buildTimeFields() {
    return List.generate(_timesPer, (index) {
      // Ensure we have enough times in our list
      while (_selectedTimes.length < _timesPer) {
        _selectedTimes.add(TimeOfDay.now());
      }
      
      return Padding(
        padding: EdgeInsets.only(bottom: index < _timesPer - 1 ? 16 : 0),
        child: InkWell(
          onTap: () => _selectTime(context, index),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Reminder Time ${index + 1}',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            child: Text(_selectedTimes[index].format(context)),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.medication != null ? 'Edit Medication' : 'Add Medication',
          style: TextStyle(fontWeight: FontWeight.w600)
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
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
                        _buildLineField(label: widget.prescription.date,size: 16),
                      ],
                    ),
                    SizedBox(width: 16),
                    // Patient Info on Right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLineField(label: 'DR: ${widget.prescription.doctor}',size: 16),
                          // SizedBox(height: 12),
                          _buildLineField(label: 'Ch: ${widget.prescription.chamber}',size: 12),

                          Divider(
                          ),
                          _buildLineField(label: 'Name: ${widget.prescription.patient}',size: 16),
                          _buildLineField(label: 'To: ${widget.prescription.medicationTo}',size: 12),

                        ],
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 1, color: Colors.black87),
              ],
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medication Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Medication Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _dosageController,
                      decoration: InputDecoration(
                        labelText: 'Dosage',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule & Stock',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        labelText: 'Medication Stock',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Required';
                        if (int.tryParse(value) == null) return 'Please enter a valid number';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _frequency,
                      decoration: InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: _frequencyOptions.map((String frequency) {
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(frequency),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _frequency = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _timesPer,
                      decoration: InputDecoration(
                        labelText: 'Times per $_frequency',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: [1,2,3].map((int times) {
                        return DropdownMenuItem(
                          value: times,
                          child: Text(times.toString()),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _timesPer = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ..._buildTimeFields(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Add any additional instructions or notes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Medication Status'),
                      subtitle: Text(_isActive ? 'Active' : 'Inactive'),
                      value: _isActive,
                      onChanged: (bool value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final medication = Medication(
                    id: widget.medication?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    dosage: _dosageController.text,
                    timesPerDay: _timesPer,
                    stock: int.parse(_stockController.text),
                    isActive: _isActive,
                    notes: _noteController.text,
                    frequency: _frequency,
                    reminderTimes: _selectedTimes,
                  );

                  if (widget.medication != null) {
                    // Update existing medication
                    updateMedicationInPrescription(widget.prescription.uid, medication);
                  } else {
                    // Add new medication
                    addMedicationToPrescription(widget.prescription.uid, medication);
                  }

                  Navigator.pop(context); // Go back after saving
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.medication != null ? 'Update Medication' : 'Save Medication',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> addMedicationToPrescription(String uid, Medication med) async {
    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');

    if (listString != null) {
      List decoded = jsonDecode(listString);
      List<Prescription> prescriptions = decoded
          .map((e) => Prescription.fromJson(e))
          .toList();

      final index = prescriptions.indexWhere((rx) => rx.uid == uid);
      if (index != -1) {
        prescriptions[index].medications.add(med);

        // Save updated list back
        final updatedString = jsonEncode(prescriptions.map((e) => e.toJson()).toList());
        await prefs.setString('prescriptions', updatedString);
      }
    }
  }

  Future<void> updateMedicationInPrescription(String uid, Medication med) async {
    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');

    if (listString != null) {
      List decoded = jsonDecode(listString);
      List<Prescription> prescriptions = decoded
          .map((e) => Prescription.fromJson(e))
          .toList();

      final prescriptionIndex = prescriptions.indexWhere((rx) => rx.uid == uid);
      if (prescriptionIndex != -1) {
        final medicationIndex = prescriptions[prescriptionIndex].medications
            .indexWhere((m) => m.id == med.id);
        
        if (medicationIndex != -1) {
          // Replace the existing medication
          prescriptions[prescriptionIndex].medications[medicationIndex] = med;

          // Save updated list back
          final updatedString = jsonEncode(prescriptions.map((e) => e.toJson()).toList());
          await prefs.setString('prescriptions', updatedString);
        }
      }
    }
  }

}

Widget _buildLineField({required String label,required double size}) {
  return Text(
    label,
    style: TextStyle(fontSize: size, fontWeight: FontWeight.w500),
  );
}


