class Prescription {
  final String medication;
  final String doctor;
  final String date;
  final String chamber;

  Prescription({
    required this.medication,
    required this.doctor,
    required this.date,
    required this.chamber,
  });

  Map<String, dynamic> toJson() => {
    'medication': medication,
    'doctor': doctor,
    'date': date,
    'chamber': chamber,
  };

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
    medication: json['medication'],
    doctor: json['doctor'],
    date: json['date'],
    chamber: json['chamber'],
  );
}
