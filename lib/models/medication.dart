
class Medication {

  late String id; // Your custom ID (e.g., DateTime string)

  late String name;

  late String dosage;

  late int timesPerDay;

  late int stock;

  late bool isActive;

  String? notes;

  late String frequency;

  @override
  String toString() {
    return 'Medication(name: $name, dosage: $dosage, timesPerDay: $timesPerDay, stock: $stock, isActive: $isActive, frequency: $frequency)';
  }
}
