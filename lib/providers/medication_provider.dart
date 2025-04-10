import 'package:flutter/material.dart';

import '../models/medication.dart';
class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];
  Box<Medication>? _medicationBox; // Changed from late to nullable
  List<Medication> get medications => _medications;

  Future<void> initialize() async {
    _medicationBox = await Hive.openBox<Medication>('medications');

    _loadMedications();
  }
  // Load medications from Hive
  void _loadMedications() {
    _medications = _medicationBox!.values.toList();
    notifyListeners();
  }

  Future<void> addMedication(Medication med) async {
    if (_medicationBox == null) {
      await initialize(); // Initialize if not done
    }
    _medications.add(med);
    await _medicationBox!.put(med.id, med); // Note the ! operator
    notifyListeners();
  }

  // Update all other methods to check _medicationBox first
  Future<void> updateMedication(Medication med) async {
    if (_medicationBox == null) return;

    final index = _medications.indexWhere((m) => m.id == med.id);
    if (index >= 0) {
      _medications[index] = med;
      await _medicationBox!.put(med.id, med);
      notifyListeners();
    }
  }
}