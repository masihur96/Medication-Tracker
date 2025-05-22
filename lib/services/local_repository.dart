

import 'dart:convert';
import 'dart:io';

import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalRepository {

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
    if (prescription != null) {
      prescriptions.removeWhere((p) => p.uid == prescription.uid);
    }
    // Add the prescription (new or updated)
    prescriptions.add(prescription);
    // Save updated list
    final String encodedList =
    jsonEncode(prescriptions.map((e) => e.toJson()).toList());
    await prefs.setString('prescriptions', encodedList);
  }
  Future<List<Prescription>> loadPrescriptions() async {

    final prefs = await SharedPreferences.getInstance();
    List<Prescription> prescriptions = [];
    final String? listString = prefs.getString('prescriptions');
    if (listString != null) {

      try{
        final List decoded = jsonDecode(listString);
        final List<Prescription> loaded =
        decoded.map((e) => Prescription.fromJson(e)).toList();
          prescriptions = loaded;
      }catch(e){
        print("loadPrescriptions$e");
      }
    }

    return prescriptions;
  }
  Future<void> updatePrescription(Prescription updatedPrescription) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingListString = prefs.getString('prescriptions');
    List<Prescription> prescriptions = [];

    if (existingListString != null) {
      final List decodedList = jsonDecode(existingListString);
      prescriptions = decodedList.map((e) => Prescription.fromJson(e)).toList();
    }

    // Remove old version
    prescriptions.removeWhere((p) => p.uid == updatedPrescription.uid);

    // Add updated version
    prescriptions.add(updatedPrescription);

    // Save back
    final String encodedList =
    jsonEncode(prescriptions.map((e) => e.toJson()).toList());
    await prefs.setString('prescriptions', encodedList);
  }

  Future<void> deletePrescription(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingListString = prefs.getString('prescriptions');

    print("fdfsfdf$existingListString");
    List<Prescription> prescriptions = [];

    if (existingListString != null) {
      final List decodedList = jsonDecode(existingListString);
      prescriptions = decodedList.map((e) => Prescription.fromJson(e)).toList();
    }

    // Remove the matching item
    prescriptions.removeWhere((p) => p.uid == uid);

    // Save back
    final String encodedList =
    jsonEncode(prescriptions.map((e) => e.toJson()).toList());
    await prefs.setString('prescriptions', encodedList);
  }

  Future<void> addMedicationToPrescription(String prescriptionId, Medication newMed) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingListString = prefs.getString('prescriptions');

    if (existingListString == null) return;

    List decodedList = jsonDecode(existingListString);
    List<Prescription> prescriptions = decodedList.map((e) => Prescription.fromJson(e)).toList();

    final index = prescriptions.indexWhere((p) => p.uid == prescriptionId);
    if (index == -1) return;

    // Add the medication
    prescriptions[index].medications.add(newMed);

    // Save
    final String updatedList = jsonEncode(prescriptions.map((e) => e.toJson()).toList());
    await prefs.setString('prescriptions', updatedList);
  }


  Future<void> updateMedication(String prescriptionId, Medication updatedMed) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingListString = prefs.getString('prescriptions');

    if (existingListString == null) return;

    List decodedList = jsonDecode(existingListString);
    List<Prescription> prescriptions = decodedList.map((e) => Prescription.fromJson(e)).toList();

    final prescriptionIndex = prescriptions.indexWhere((p) => p.uid == prescriptionId);
    if (prescriptionIndex == -1) return;

    final meds = prescriptions[prescriptionIndex].medications;
    final medIndex = meds.indexWhere((m) => m.id == updatedMed.id);
    if (medIndex == -1) return;

    // Update medication
    meds[medIndex] = updatedMed;

    // Save
    final String updatedList = jsonEncode(prescriptions.map((e) => e.toJson()).toList());
    await prefs.setString('prescriptions', updatedList);
  }


  Future<void> deleteMedication(String prescriptionId, String medicationId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingListString = prefs.getString('prescriptions');

    if (existingListString == null) return;

    List decodedList = jsonDecode(existingListString);
    List<Prescription> prescriptions = decodedList.map((e) => Prescription.fromJson(e)).toList();

    final prescriptionIndex = prescriptions.indexWhere((p) => p.uid == prescriptionId);
    if (prescriptionIndex == -1) return;

    prescriptions[prescriptionIndex].medications.removeWhere((m) => m.id == medicationId);

    final String updatedList = jsonEncode(prescriptions.map((e) => e.toJson()).toList());
    await prefs.setString('prescriptions', updatedList);
  }
  Future<String?> exportData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? listString = prefs.getString('prescriptions');
      if (listString != null) {
        return listString; // Already a JSON string
      }
      return null; // No data to export
    } catch (e) {
      print("Error exporting data: $e");
      return null;
    }
  }



  Future<File?> exportDataToFile() async {
    try {
      final String? jsonData = await exportData();
      if (jsonData == null) return null;

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/prescriptions_export.json');

      await file.writeAsString(jsonData);
      return file;
    } catch (e) {
      print("Error exporting to file: $e");
      return null;
    }
  }


 static Future<void> deleteAllData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

}