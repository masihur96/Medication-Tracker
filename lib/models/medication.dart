import 'package:hive/hive.dart';

part 'medication.g.dart'; // This will be generated later

@HiveType(typeId: 0) // Each model needs a unique typeId (0, 1, 2...)
class Medication {
  @HiveField(0) // Each field needs a unique number
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final List<int> timesPerDay;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timesPerDay,
  });
}