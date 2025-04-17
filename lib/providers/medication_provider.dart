import 'package:flutter/material.dart';
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



}