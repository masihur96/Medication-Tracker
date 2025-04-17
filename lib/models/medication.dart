import 'package:flutter/material.dart';

class Medication {
  late String id;
  late String name;
  late String dosage;
  late int timesPerDay;
  late int stock;
  late bool isActive;
  String? notes;
  late String frequency;
  late List<TimeOfDay> reminderTimes; // Changed to TimeOfDay ✅

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timesPerDay,
    required this.stock,
    required this.isActive,
    this.notes,
    required this.frequency,
    required this.reminderTimes,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      timesPerDay: json['timesPerDay'],
      stock: json['stock'],
      isActive: json['isActive'],
      notes: json['notes'],
      frequency: json['frequency'],
      reminderTimes: (json['reminderTimes'] as List<dynamic>?)
          ?.map((timeString) => _stringToTimeOfDay(timeString))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'timesPerDay': timesPerDay,
      'stock': stock,
      'isActive': isActive,
      'notes': notes,
      'frequency': frequency,
      'reminderTimes': reminderTimes.map((time) => _timeOfDayToString(time)).toList(),
    };
  }

  static String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static TimeOfDay _stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  String toString() {
    return 'Medication(name: $name, dosage: $dosage, reminderTimes: ${reminderTimes.map(_timeOfDayToString).join(', ')})';
  }
}
