class EnhancedMedicationHistory {
  final String prescriptionId;
  final String prescriptionName;
  final String date;
  final String medicationName;
  final String dosage;
  final String notes;
  final List<String> medicationTimes;
  final List<bool> isTaken;
  final String doctorName;
  final String patientName;
  final int patientAge;

  EnhancedMedicationHistory({
    required this.prescriptionId,
    required this.prescriptionName,
    required this.date,
    required this.medicationName,
    required this.dosage,
    required this.notes,
    required this.medicationTimes,
    required this.isTaken,
    required this.doctorName,
    required this.patientName,
    required this.patientAge,
  });

  factory EnhancedMedicationHistory.fromJson(Map<String, dynamic> json) {
    return EnhancedMedicationHistory(
      prescriptionId: json['prescriptionId'],
      prescriptionName: json['prescriptionName'],
      date: json['date'],
      medicationName: json['medicationName'],
      dosage: json['dosage'],
      notes: json['notes'],
      medicationTimes: List<String>.from(json['medicationTimes']),
      isTaken: List<bool>.from(json['isTaken']),
      doctorName: json['doctorName'] ?? '',
      patientName: json['patientName'] ?? '',
      patientAge: json['patientAge'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescriptionId': prescriptionId,
      'prescriptionName': prescriptionName,
      'date': date,
      'medicationName': medicationName,
      'dosage': dosage,
      'notes': notes,
      'medicationTimes': medicationTimes,
      'isTaken': isTaken,
      'doctorName': doctorName,
      'patientName': patientName,
      'patientAge': patientAge,
    };
  }
} 