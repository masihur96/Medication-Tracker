class Prescription {
  final String medication;
  final String uid;
  final String doctor;
  final String date;
  final String chamber;
  final String patient;

  Prescription({
    required this.medication,
    required this.uid,
    required this.doctor,
    required this.date,
    required this.chamber,
    required this.patient,
  });

  Map<String, dynamic> toJson() => {
    'medication': medication,
    'uid': uid,
    'doctor': doctor,
    'date': date,
    'chamber': chamber,
    'patient': patient,
  };

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
    medication: json['medication']??"",
    uid: json['uid']??"",
    doctor: json['doctor']??"",
    date: json['date']??"",
    chamber: json['chamber']??"",
    patient: json['patient']??"",
  );
}
