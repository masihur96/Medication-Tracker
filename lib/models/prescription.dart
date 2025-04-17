import 'medication.dart';

class Prescription {
  final String uid;
  final String doctor;
  final String date;
  final String chamber;
  final String patient;
  final String medicationTo;
  final List<Medication> medications;

  Prescription({
    required this.uid,
    required this.doctor,
    required this.date,
    required this.chamber,
    required this.patient,
    required this.medicationTo,
    required this.medications,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      uid: json['uid']??"",
      doctor: json['doctor']??"",
      date: json['date']??"",
      chamber: json['chamber']??"",
      patient: json['patient']??"",
      medicationTo: json['medicationTo']??"",
      medications: (json['medications'] as List)
          .map((e) => Medication.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'doctor': doctor,
      'date': date,
      'chamber': chamber,
      'patient': patient,
      'medicationTo': medicationTo,
      'medications': medications.map((e) => e.toJson()).toList(),
    };
  }
}
