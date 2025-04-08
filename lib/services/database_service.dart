import 'package:hive/hive.dart';
import 'package:med_track/models/medication.dart';

class DatabaseService {
  static const String _medBox = 'medications';

  Future<void> init() async {
    await Hive.openBox<Medication>(_medBox);
  }

  Future<void> saveMedication(Medication med) async {
    final box = Hive.box<Medication>(_medBox);
    await box.put(med.id, med);
  }

  List<Medication> getMedications() {
    final box = Hive.box<Medication>(_medBox);
    return box.values.toList();
  }
}