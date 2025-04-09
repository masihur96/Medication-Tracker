import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MedicationScheduleScreen extends StatefulWidget {
  const MedicationScheduleScreen({super.key});

  @override
  State<MedicationScheduleScreen> createState() => _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Schedule'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _getMedicationsForSelectedDay().length,
              itemBuilder: (context, index) {
                final medication = _getMedicationsForSelectedDay()[index];
                return _buildScheduleItem(medication);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getMedicationsForSelectedDay() {
    // TODO: Replace with actual medication data from your database
    return [
      {
        'name': 'Medication A',
        'time': '08:00',
        'dosage': '1 tablet',
      },
      {
        'name': 'Medication B',
        'time': '12:00',
        'dosage': '2 tablets',
      },
      {
        'name': 'Medication C',
        'time': '20:00',
        'dosage': '1 tablet',
      },
    ];
  }

  Widget _buildScheduleItem(Map<String, String> medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.medication),
        ),
        title: Text(
          medication['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${medication['time']} - ${medication['dosage']}'),
        trailing: Checkbox(
          value: false, // TODO: Track completion status
          onChanged: (bool? value) {
            // TODO: Update completion status
          },
        ),
      ),
    );
  }
} 