import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_medication_history.dart';
import 'package:intl/intl.dart';

import 'package:pdf/widgets.dart' as pw;

class HistoryScreen extends StatefulWidget {

  const HistoryScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<EnhancedMedicationHistory> _medicationHistory = [];

bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    // Initialize data
    initializeData();
  }

  Future<void> initializeData() async {
    setState(() => _isLoading = true);
    await loadMedicationHistory();
    setState(() => _isLoading = false);
  }

  Future<void> loadMedicationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('history');
    if (historyString != null) {
      final List decoded = jsonDecode(historyString);
      setState(() {
        _medicationHistory = decoded
            .map((e) => EnhancedMedicationHistory.fromJson(e))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    final sortedHistory = List<EnhancedMedicationHistory>.from(_medicationHistory)
      ..sort((a, b) {
        final aDate = _parseDate(a.date);
        final bDate = _parseDate(b.date);
        return bDate.compareTo(aDate);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.medicationHistory),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white,),
            onPressed: () => _generateAndOpenPDF(),
          ),
        ],
      ),
      body: sortedHistory.isEmpty
          ? Center(
              child: Text(localizations.noMedicationsScheduled),
            )
          : ListView.builder(
              itemCount: sortedHistory.length,
              itemBuilder: (context, index) {
                final history = sortedHistory[index];
                return _buildHistoryCard(history);
              },
            ),
    );
  }

  DateTime _parseDate(String date) {
    final parts = date.split('/');
    return DateTime(
      int.parse(parts[2]), // year
      int.parse(parts[1]), // month
      int.parse(parts[0]), // day
    );
  }

  Widget _buildHistoryCard(EnhancedMedicationHistory history) {
    final localizations = AppLocalizations.of(context);
    final date = _parseDate(history.date);
    final formattedDate = DateFormat('MMMM d, yyyy').format(date);

    // Calculate adherence percentage
    final takenCount = history.isTaken.where((taken) => taken).length;
    final totalCount = history.isTaken.length;
    final adherencePercentage = (takenCount / totalCount * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAdherenceColor(adherencePercentage),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${adherencePercentage}% ${localizations.taken}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${localizations.prescriptions}: ${history.prescriptionName}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${history.medicationName} - ${history.dosage}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (history.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${localizations.notes}: ${history.notes}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                history.medicationTimes.length,
                (index) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: history.isTaken[index] ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${history.medicationTimes[index]} - ${history.isTaken[index] ? localizations.taken : localizations.notTakenYet}',
                    style: TextStyle(
                      color: history.isTaken[index] ? Colors.green[900] : Colors.red[900],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  Color _getAdherenceColor(int percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}