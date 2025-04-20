import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  DateTime? _selectedDay = DateTime.now();
  
  List<Prescription> _prescriptions = [];
  Prescription? _selectedPrescription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPrescriptions();
  }

  Future<void> loadPrescriptions() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');

    if (listString != null) {
      final List decoded = jsonDecode(listString);
      final List<Prescription> loaded =
      decoded.map((e) => Prescription.fromJson(e)).toList();
      setState(() {
        _prescriptions = loaded;
        _isLoading = false;
      });
      _selectedPrescription = _prescriptions.first;
    } else {
      setState(() => _isLoading = false);
    }
  }
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); // e.g., 08:00 AM
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          localizations.medicationHistory,
          style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print,color: Colors.white,),
            onPressed: () => _generateAndOpenPDF(),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<Prescription>(
              isExpanded: true,
              hint: Text(localizations.selectPrescription),
              value: _selectedPrescription,
              items: _prescriptions.map((prescription) {
                return DropdownMenuItem<Prescription>(
                  value: prescription,
                  child: Text('${localizations.doctor} ${prescription.doctor} - ${_formatDisplayDate(prescription.date)}'),
                );
              }).toList(),
              onChanged: (Prescription? newValue) {
                setState(() {
                  _selectedPrescription = newValue;
                  // Reset calendar to prescription date
                  if (newValue != null) {
                    try {
                      final prescriptionDate = DateFormat('dd/M/yyyy').parse(newValue.date);
                      _selectedDay = prescriptionDate;
                      _focusedDay = prescriptionDate;
                    } catch (e) {
                      print('Error parsing date: ${newValue.date}');
                    }
                  }
                });
              },
            ),
          ),
          
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            locale: Localizations.localeOf(context).languageCode,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: (day) {
              if (_selectedPrescription == null) return [];
              return _getMedicationsForDay(day, _selectedPrescription!);
            },
            calendarStyle: CalendarStyle(
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
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
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              localizations.todaysMedications,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedPrescription == null
                    ? Center(child: Text(localizations.selectPrescription))
                    : _selectedDay != null
                        ? _buildMedicationList()
                        : Center(
                            child: Text(localizations.selectDateToViewMedications),
                          ),
          ),
        ],
      ),
    );
  }

  List<Medication> _getMedicationsForDay(DateTime day, Prescription prescription) {
    try {
      final prescriptionDate = DateFormat('dd/M/yyyy').parse(prescription.date);
      
      bool isValidDate = prescription.medications.any((medication) {
        return medication.remainderDates.any((dateStr) {
          try {
            final medicationDate = DateFormat('dd/MM/yyyy').parse(dateStr);
            return isSameDay(medicationDate, day);
          } catch (e) {
            print('Error parsing remainder date: $dateStr');
            return false;
          }
        });
      });

      if (isValidDate) {
        return prescription.medications;
      }
    } catch (e) {
      print('Error parsing date: ${prescription.date}');
    }
    return [];
  }

  Widget _buildMedicationList() {
    final localizations = AppLocalizations.of(context);
    
    // Get medications for the selected date only
    final medications = _selectedPrescription!.medications.where((medication) {
      return medication.remainderDates.any((dateStr) {
        try {
          final medicationDate = DateFormat('dd/MM/yyyy').parse(dateStr);
          return isSameDay(medicationDate, _selectedDay!);
        } catch (e) {
          print('Error parsing remainder date: $dateStr');
          return false;
        }
      });
    }).toList();
    
    if (medications.isEmpty) {
      return Center(child: Text(localizations.noMedicationsScheduled));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final medication = medications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.medication, color: Colors.white),
            ),
            title: Text(
              medication.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${localizations.timesPerDay}: ${medication.timesPerDay}'),
                if (medication.notes?.isNotEmpty ?? false)
                  Text('${localizations.notes}: ${medication.notes}'),
                ...List.generate(medication.timesPerDay, (index) {
                  final bool taken = index < medication.isTaken.length ? medication.isTaken[index] : false;
                  final String time = (medication.reminderTimes != null && index >= 0 && index < medication.reminderTimes.length)
                      ? formatTimeOfDay(medication.reminderTimes[index])
                      : localizations.notSet;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          taken ? Icons.check_circle : Icons.schedule,
                          color: taken ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text('$time - ${taken ? localizations.taken : localizations.notTakenYet}'),
                      ],
                    ),
                  );
                }),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  // Function to convert TimeOfDay to String
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final DateTime dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.jm().format(dateTime); // Formats as '8:29 AM'
  }

  String getReminderTime(List<String> times, int index) {
    return index < times.length ? times[index] : 'N/A';
  }

  String _formatDisplayDate(String date) {
    try {
      final DateTime parsedDate = DateFormat('dd/M/yyyy').parse(date);
      return DateFormat.yMMMMd(Localizations.localeOf(context).languageCode).format(parsedDate);
    } catch (e) {
      return date;
    }
  }


  Future<void> _generateAndOpenPDF() async {
    final localizations = AppLocalizations.of(context);
    final pdf = pw.Document();

    // TODO: Get actual patient info from your user/profile system
    final String patientName = 'John Doe'; // This should come from user profile
    final int patientAge = 35; // This should come from user profile

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
            child: pw.Text(localizations.medicationHistory),
          ),
          pw.Text('${localizations.name}: $patientName'),
          pw.Text('${localizations.age}: $patientAge'),
          pw.SizedBox(height: 20),

          // Loop through each date and print a table
          ...medicationHistory.entries.map((entry) {
            final date = DateFormat('yyyy-MM-dd').format(entry.key);
            final meds = entry.value;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${localizations.date}: $date', 
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: [
                    localizations.medication,
                    localizations.time,
                    localizations.dosage,
                    localizations.status,
                    localizations.takenAt
                  ],
                  data: meds.map((med) {
                    return [
                      med['name'],
                      med['time'],
                      med['dosage'],
                      med['taken'] ? localizations.taken : localizations.notTakenYet,
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
  String _formatDateTime(DateTime dateTime) {
    return DateFormat.jm(Localizations.localeOf(context).languageCode).format(dateTime);
  }


} 