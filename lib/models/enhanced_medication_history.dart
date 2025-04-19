class EnhancedMedicationHistory {
  final String prescriptionId;
  final String prescriptionName;
  final String date;
  final String medicationName;
  final String dosage;
  final String? notes;
  final List<String> medicationTimes;
  final List<bool> isTaken;

  EnhancedMedicationHistory({
    required this.prescriptionId,
    required this.prescriptionName,
    required this.date,
    required this.medicationName,
    required this.dosage,
    this.notes,
    required this.medicationTimes,
    required this.isTaken,
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
    };
  }
} 