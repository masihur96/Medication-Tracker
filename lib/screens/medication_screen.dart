import 'package:flutter/material.dart';

import 'add_medication_screen.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, bool> _alarmStates = {};  // To track alarm states for each medication

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Medications'),
            Tab(text: 'Available Stock'),
            Tab(text: 'Active'),
            Tab(text: 'Inactive'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMedicationList(),
          _buildAvailableStock(),
          _buildActiveMedications(),
          _buildInactiveMedications(),
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildMedicationItem(
          name: 'Medication ${String.fromCharCode(65 + index)}',
          dosage: '${index + 1} tablet(s)',
          frequency: 'Daily',
          timeOfDay: '${8 + (index * 4)}:00',
          notes: 'Take with food',
        );
      },
    );
  }

  Widget _buildAvailableStock() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            title: Text('Medication ${String.fromCharCode(65 + index)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Stock: ${(index + 1) * 10} tablets'),
                Text('Expiry Date: ${DateTime.now().add(Duration(days: 30 * (index + 1))).toString().substring(0, 10)}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveMedications() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 2,
      itemBuilder: (context, index) {
        return _buildMedicationItem(
          name: 'Active Med ${String.fromCharCode(65 + index)}',
          dosage: '${index + 1} tablet(s)',
          frequency: 'Daily',
          timeOfDay: '${8 + (index * 4)}:00',
          notes: 'Active medication',
        );
      },
    );
  }

  Widget _buildInactiveMedications() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 2,
      itemBuilder: (context, index) {
        return _buildMedicationItem(
          name: 'Inactive Med ${String.fromCharCode(65 + index)}',
          dosage: '${index + 1} tablet(s)',
          frequency: 'Not taking',
          timeOfDay: 'N/A',
          notes: 'Discontinued',
        );
      },
    );
  }

  Widget _buildMedicationItem({
    required String name,
    required String dosage,
    required String frequency,
    required String timeOfDay,
    required String notes,
  }) {
    // Initialize alarm state for this medication if not exists
    _alarmStates[name] ??= false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        children: [
          Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.medication, size: 16),
                        const SizedBox(width: 8),
                        Text('Dosage: $dosage'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text('Frequency: $frequency'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Text('Time: $timeOfDay'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.note, size: 16),
                        const SizedBox(width: 8),
                        Text('Notes: $notes'),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        // TODO: Navigate to edit medication screen
                        break;
                      case 'delete':
                        // TODO: Show delete confirmation dialog
                        break;
                    }
                  },
                ),
              ),
            ],
          ),
          // New alarm control positioned at top right
          if (frequency != 'Not taking')
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _alarmStates[name] = !(_alarmStates[name] ?? false);
                  });
                  
                  if (_alarmStates[name]!) {
                    // Alarm is turned ON
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Alarm enabled for $name'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    // TODO: Add your alarm setup logic here
                  } else {
                    // Alarm is turned OFF
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Alarm disabled for $name'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    // TODO: Add your alarm cancellation logic here
                  }
                },
                icon: Icon(
                  _alarmStates[name]! ? Icons.alarm_on : Icons.alarm_off,
                  size: 20,
                  color: _alarmStates[name]! ? Colors.blue : Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 