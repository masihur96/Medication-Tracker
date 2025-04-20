import 'package:flutter/material.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/providers/medication_provider.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:provider/provider.dart';


class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          localizations.notifications,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Consumer<MedicationProvider>(
        builder: (context, medicationProvider, child) {
          final medications = medicationProvider.medications;
          
          if (medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                  ),
                  SizedBox(height: 24),
                  Text(
                    localizations.noMedications,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    localizations.noMedicationsScheduled,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return _buildNotificationCard(medication,context);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Medication medication,BuildContext context) {

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: medication.isActive 
                ? Colors.green.shade100 
                : Colors.grey.shade100,
          ),
          child: Icon(
            Icons.medication,
            size: 28,
            color: medication.isActive 
                ? Colors.green.shade700 
                : Colors.grey.shade700,
          ),
        ),
        title: Text(
          medication.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            _buildInfoRow(Icons.medical_information, '${AppLocalizations.of(context).dosage}: ${medication.timesPerDay}'),
            SizedBox(height: 4),
            _buildInfoRow(Icons.schedule, '${AppLocalizations.of(context).frequency}: ${medication.frequency}'),
            SizedBox(height: 4),
            _buildInfoRow(Icons.alarm, '${AppLocalizations.of(context).time}: ${_formatTime(60)}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[700]),
          onPressed: () {
            // Add action menu or navigation to medication details
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }
} 