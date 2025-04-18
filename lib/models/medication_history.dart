class MedicationHistory {
  final String medicationId;
  final String medicationName;
  final String dosage;
  final String date;
  final String time;
  bool isTaken; // ✅ Make this mutable (remove `late`, not `final`)

  MedicationHistory({
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.date,
    required this.time,
    this.isTaken = false, // ✅ Set default value
  });

  factory MedicationHistory.fromJson(Map<String, dynamic> json) {
    return MedicationHistory(
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      dosage: json['dosage'],
      date: json['date'],
      time: json['time'],
      isTaken: json['isTaken'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'date': date,
      'time': time,
      'isTaken': isTaken,
    };
  }
}
