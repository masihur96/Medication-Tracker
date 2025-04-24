import 'medication.dart';

class Prescription {
  final String uid;
  final String doctor;
  final String date;
  final String patient;
  final int? age;  //;
  final List<Medication> medications;

  Prescription({
    required this.uid,
    required this.doctor,
    required this.date,
    required this.patient,
    required this.age,
    required this.medications,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      uid: json['uid']??"",
      doctor: json['doctor']??"",
      date: json['date']??"",
      patient: json['patient']??"",
      age: json['age']??0,
      medications: (json['medications'] as List<dynamic>?)
          ?.map((e) => Medication.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'doctor': doctor,
      'date': date,
      'age': age,
      'patient': patient,
      'medications': medications.map((e) => e.toJson()).toList(),
    };
  }
}
