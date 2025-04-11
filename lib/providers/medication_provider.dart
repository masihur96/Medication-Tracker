import 'package:flutter/material.dart';
import 'package:med_track/main.dart';

import '../models/medication.dart';
class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];
  List<Medication> get medications => _medications;

  Future<void> initialize() async {
    _loadMedications();
  }
  // Load medications from Hive
  void _loadMedications() {
    _medications = [];
    notifyListeners();
  }

  Future<void> addMedication(Medication med) async {
    await isar.writeTxn(() async {
      await isar.medications.put(Medication()
        ..id = DateTime.now().toString()
        ..name = 'Paracetamol'
        ..dosage = '500mg'
        ..timesPerDay = med.timesPerDay
        .. stock =med.stock
        ..isActive = med.isActive
        ..notes = med.notes
        .. frequency = med.frequency);
    });
// Note the ! operator
    notifyListeners();
  }


}