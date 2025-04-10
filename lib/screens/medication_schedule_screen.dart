import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _generateAndOpenPDF(),
          ),
        ],
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

  List<Map<String, dynamic>> _getMedicationsForSelectedDay() {
    // TODO: Replace with actual medication data from your database
    return [
      {
        'name': 'Medication A',
        'time': '08:00',
        'dosage': '1 tablet',
        'taken': true,
        'takenAt': DateTime(2024, 3, 15, 8, 5), // Example timestamp
      },
      {
        'name': 'Medication B',
        'time': '12:00',
        'dosage': '2 tablets',
        'taken': true,
        'takenAt': DateTime(2024, 3, 15, 12, 3),
      },
      {
        'name': 'Medication C',
        'time': '20:00',
        'dosage': '1 tablet',
        'taken': false,
        'takenAt': null,
      },
    ];
  }

  Widget _buildScheduleItem(Map<String, dynamic> medication) {
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${medication['time']} - ${medication['dosage']}'),
            if (medication['taken'])
              Text(
                'Taken at: ${_formatDateTime(medication['takenAt'])}',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Checkbox(
          value: medication['taken'],
          onChanged: (bool? value) {
            setState(() {
              medication['taken'] = value;
              medication['takenAt'] = value == true ? DateTime.now() : null;
            });
          },
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _generateAndOpenPDF() async {
    final pdf = pw.Document();

    final String patientName = 'John Doe';
    final int patientAge = 35;

    // Example mock grouped data — replace this with your real grouped data
    Map<DateTime, List<Map<String, dynamic>>> medicationHistory = {
      DateTime(2024, 3, 15): [
        {
          'name': 'Medication A',
          'time': '08:00',
          'dosage': '1 tablet',
          'taken': true,
          'takenAt': DateTime(2024, 3, 15, 8, 5),
        },
        {
          'name': 'Medication B',
          'time': '12:00',
          'dosage': '2 tablets',
          'taken': true,
          'takenAt': DateTime(2024, 3, 15, 12, 3),
        },
        {
          'name': 'Medication C',
          'time': '20:00',
          'dosage': '1 tablet',
          'taken': false,
          'takenAt': null,
        },
      ],
      DateTime(2024, 3, 16): [
        {
          'name': 'Medication D',
          'time': '08:00',
          'dosage': '1 tablet',
          'taken': true,
          'takenAt': DateTime(2024, 3, 16, 8, 10),
        },
      ],
    };

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Medication History'),
          ),
          pw.Text('Name: $patientName'),
          pw.Text('Age: $patientAge'),
          pw.SizedBox(height: 20),

          // Loop through each date and print a table
          ...medicationHistory.entries.map((entry) {
            final date = DateFormat('yyyy-MM-dd').format(entry.key);
            final meds = entry.value;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Date: $date', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ['Medication', 'Time', 'Dosage', 'Status', 'Taken At'],
                  data: meds.map((med) {
                    return [
                      med['name'],
                      med['time'],
                      med['dosage'],
                      med['taken'] ? 'Taken' : 'Not Taken',
                      med['taken']
                          ? _formatDateTime(med['takenAt'])
                          : '-',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.center,
                    3: pw.Alignment.center,
                    4: pw.Alignment.center,
                  },
                ),
                pw.SizedBox(height: 30),
              ],
            );
          }).toList(),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/medication_history.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }



} 