
class MedicationHistory {
  final String medicationId;
  final String medicationName;
  final String dosage;
  final String date; // e.g. "2025-04-17"
  final String time; // e.g. "08:00"
  final bool isTaken;

  MedicationHistory({
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.date,
    required this.time,
    required this.isTaken,
  });

  factory MedicationHistory.fromJson(Map<String, dynamic> json) {
    return MedicationHistory(
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      dosage: json['dosage'],
      date: json['date'],
      time: json['time'],
      isTaken: json['isTaken'],
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

  @override
  String toString() {
    return '[$date $time] $medicationName ($dosage): ${isTaken ? "Taken" : "Pending"}';
  }
}
